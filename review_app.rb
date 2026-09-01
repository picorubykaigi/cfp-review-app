require 'js'

class ReviewApp < Funicular::Component
  include Signin
  include Index
  include Show

  RANGE   = 'A2:L'
  RATINGS = 'Ratings!A2:E'

  def initialize_state
    @proposals = Proposals.new([])
    @ratings = Ratings.new([], '')
    @session = Session.new
    @config = SheetConfig.read(local_storage, JS.global[:location][:hash].to_s)
    @history = ScreenHistory.new
    @table = TableState.new(local_storage)
    { phase: 'signin', message: '', index: 0,
      score: '', busy: false, toast: '', table_revision: 0 }
  end

  def component_mounted
    boot = JS.document.querySelector('.boot')
    boot[:style][:display] = 'none' unless boot.nil?
    if JS.global[:CFP_CLIENT_ID].to_s.empty?
      patch(phase: 'setup')
    elsif @config.missing?
      patch(phase: 'nosheet')
    end
    JS.global.addEventListener('popstate') { |_e| on_popstate }
  end

  # 再描画は入力中の値を保持する（＝提案を切り替えても前のコメントが残る）。
  # 描画後に呼ばれるフックで、表示対象が変わったときのみ textarea の中身を入れ替える。
  def component_updated(*_a)
    return unless state.phase == 'detail'

    proposal = current
    return if proposal.nil?
    return if @synced_row == proposal.row

    element = comment_el
    return if element.nil?

    @synced_row = proposal.row
    rating = @ratings.mine(proposal.row)
    element[:value] = rating.nil? ? '' : rating[1]
    score = score_el
    score[:value] = rating.nil? ? '' : rating[0] unless score.nil?
  end

  def sign_in(*_a)
    return if state.busy

    patch(busy: true, message: '')
    JS.global.cfpSignIn do |token|
      # JS から Ruby のブロックが呼ばれている文脈で、この中では fetch できない。
      # トークンを受け取るだけにして、読み込みは setTimeout に逃がす。
      @session.token = token
      JS.global.setTimeout(0) { after_sign_in }
    end
  end

  def after_sign_in
    guard('サインイン') do
      if @session.signed_in?
        load_all
      else
        patch(busy: false, message: 'サインインできませんでした。もう一度お試しください。')
      end
    end
  end

  def load_all
    patch(phase: 'loading', busy: true, message: '')
    @session.identify
    unless @session.identified?
      return fail_with('メールアドレスの権限が許可されていません。サインインし直して、同意画面で項目にチェックを入れてください。')
    end

    status, body = SheetsClient.get_values(@session.token, @config.sheet_id, RANGE)
    unless status == 200
      return fail_with("シートを読めませんでした (#{status}) #{SheetsClient.error_message(body)}")
    end

    @synced_row = nil
    @proposals = Proposals.build(SheetsClient.to_rows(body[:values]))
    load_ratings
    patch(phase: 'list', busy: false, index: 0)
  end

  # タブが無ければ 400 が返り、その場合は採点ゼロとして進む。
  def load_ratings
    status, body = SheetsClient.get_values(@session.token, @config.sheet_id, RATINGS)
    rows = status == 200 ? SheetsClient.to_rows(body[:values]) : []
    @ratings = Ratings.new(rows, @session.email)
  end

  def fail_with(message) = patch(phase: 'error', busy: false, message: message)
  def visible_proposals = @table.apply(@proposals, @ratings)
  def current = visible_proposals[state.index]
  def own?(proposal) = proposal.submitted_by?(@session.email)

  def sort_by_column(key)
    @table.sort_by(key)
    redraw_table
  end

  def reset_sort(*_a)
    @table.reset
    redraw_table
  end

  def on_filter_speaker(*_a)
    @table.speaker = filter_value('.f-speaker')
    redraw_table
  end

  def on_filter_title(*_a)
    @table.title = filter_value('.f-title')
    redraw_table
  end

  def on_filter_format(*_a)
    @table.format = filter_value('.f-format')
    redraw_table
  end

  # 値は TableState が持ち、state で再描画する
  def redraw_table = patch(table_revision: state.table_revision + 1)

  def filter_value(selector)
    element = JS.document.querySelector(selector)
    element.nil? ? '' : element[:value].to_s
  end

  def on_score_input(*_a) = patch(score: score_value)
  def save_rating(*_a) = guard('保存') { do_save }

  def do_save
    proposal = current
    return if proposal.nil? || state.busy

    score = state.score.to_s.to_f
    if score < 1 || score > 5
      flash('Rating must be between 1 and 5.')
      return
    end

    comment = comment_value
    patch(busy: true, toast: '')
    status, body = SheetsClient.append(
      @session.token, @config.sheet_id, RATINGS,
      [JS.global.cfpNow.to_s, @session.email, proposal.row.to_s, score.to_s, comment]
    )
    patch(busy: false)
    if status == 200
      @ratings.record(proposal.row, @session.email, score.to_s, comment)
      flash('保存しました')
    else
      hint = status == 400 ? '「Ratings」タブが無いかもしれません。' : ''
      flash("保存に失敗 (#{status}) #{hint}#{SheetsClient.error_message(body)}")
    end
  end

  def comment_el = JS.document.querySelector('.rate-comment')
  def score_el = JS.document.querySelector('.rate-score')

  def score_value
    element = score_el
    element.nil? ? '' : element[:value].to_s
  end

  def comment_value
    element = comment_el
    element.nil? ? '' : element[:value].to_s
  end

  def move(direction) = open_at(state.index + direction)

  def open_at(index) = guard('表示') { do_open(index) }

  def do_open(index)
    list = visible_proposals
    return if list.empty?

    index = 0 if index < 0
    index = list.size - 1 if index >= list.size
    entering = state.phase != 'detail'
    rating = @ratings.mine(list[index].row)
    patch(phase: 'detail', index: index, score: rating.nil? ? '' : rating[0], toast: '')
    @history.push('list') if entering
  end

  def back_to_list(*_a)
    @history.empty? ? return_to('list') : @history.back
  end

  def on_popstate(*_a)
    return if @history.empty?

    return_to(@history.pop)
  end

  def return_to(phase)
    @synced_row = nil
    patch(phase: phase, toast: '')
  end

  def local_storage = JS.global[:localStorage]

  # PicoRuby は未捕捉例外が出るとタスクが無言で止まる。イベントハンドラは
  # 必ずここを通して、失敗を画面に出す。
  def guard(label)
    yield
  rescue => error
    patch(busy: false)
    flash("#{label}: #{error.class} #{error.message}")
  end

  def flash(message)
    patch(toast: message)
    JS.global.setTimeout(2600) { patch(toast: '') }
  end

  def render
    div(class: 'app') do
      case state.phase
      when 'setup'   then render_setup
      when 'nosheet' then render_nosheet
      when 'signin'  then render_signin
      when 'loading' then div(class: 'center') { '読み込み中…' }
      when 'error'   then render_error
      when 'list'    then render_list
      when 'detail'  then render_detail
      end
      div(class: state.toast.empty? ? 'toast' : 'toast on') { state.toast }
    end
  end
end

Funicular.start(ReviewApp, container: 'app')
