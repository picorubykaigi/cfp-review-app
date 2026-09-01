module Show
  # cfp-app の rating_tooltip（Ratings Guide）に相当する説明。
  GUIDE = [
    ['1', '問題が多く、このイベントには合わない'],
    ['2', '平凡。手を入れれば合うかもしれない'],
    ['3', 'よい。改善の余地はあるが、イベントには適している'],
    ['4', 'とてもよい。主題も合っていて、全体としてふさわしい'],
    ['5', '理想的。文句なくふさわしい提案']
  ].freeze

  def render_detail
    proposal = current
    return render_list if proposal.nil?

    total = visible_proposals.size
    div(class: 'detail-wrap') do
      div(class: 'bar') do
        button(class: 'btn btn-primary btn-sm', onclick: :back_to_list) do
          '« Return to Proposals'
        end
        div(class: 'bar-sub') { "#{state.index + 1} / #{total}" }
        button(class: 'btn btn-default btn-sm', onclick: ->(*_a) { move(-1) }) do
          'Previous Proposal'
        end
        button(class: 'btn btn-primary btn-sm', onclick: ->(*_a) { move(1) }) do
          'Next Proposal'
        end
      end

      div(class: 'page-header') do
        h1(class: 'proposal-title') { proposal.title }
      end

      div(class: 'proposal-info-bar') do
        render_meta_item('Speaker', proposal.name)
        render_meta_item('Format', proposal.format_label)
        render_meta_item('Links', speaker_links(proposal))
        ''
      end

      div(class: 'proposal-contents') do
        render_section('Abstract', proposal.abstract)
        h2(class: 'fieldset-legend') { 'For Review Committee' }
        render_section('Details', proposal.details)
        render_section('Pitch', proposal.pitch)
        render_section('Demo details', proposal.demo)
        render_section('Speaker Bio', proposal.bio)
        ''
      end

      render_rating(proposal)
      render_others(proposal)
    end
  end

  def render_meta_item(label, value)
    return '' if value.nil? || value.empty?
    div(class: 'proposal-meta-item') do
      div(class: 'info-item-heading') { label }
      div(class: 'info-item-value') { value }
    end
  end

  def render_section(label, text)
    return '' if text.nil? || text.empty?
    div(class: 'proposal-section') do
      h3(class: 'control-label') { label }
      div(class: 'markdown') { text }
    end
  end

  def render_rating(proposal)
    div(class: 'rate') do
      div(class: 'rate-row') do
        div(class: 'rate-label') { 'Rating' }
        now = state.score.to_s.to_i
        ['1', '2', '3', '4', '5'].each do |value|
          button(class: now >= value.to_i ? 'star on' : 'star',
                 onclick: ->(*_a) { set_score(value) }) { '★' }
        end
        button(class: 'guide-btn', onclick: :toggle_guide) { 'ⓘ' }
      end
      if state.guide
        render_guide
      end
      textarea(class: 'rate-comment', placeholder: 'Comment (optional)') { '' }
      div(class: 'rate-foot') do
        button(class: 'btn btn-primary', onclick: :save_rating) do
          state.busy ? 'Saving…' : 'Save'
        end
        div(class: 'rate-note') do
          @ratings.rated?(proposal.row) ? 'Saving again replaces your rating.' : ''
        end
      end
    end
  end

  def render_guide
    div(class: 'guide') do
      div(class: 'guide-head') { 'Ratings Guide' }
      GUIDE.each do |guide|
        div(class: 'guide-row') do
          span(class: 'guide-score') { guide[0] }
          span(class: 'guide-text') { guide[1] }
        end
      end
      ''
    end
  end

  def render_others(proposal)
    div(class: 'others') do
      if @ratings.rated?(proposal.row)
        entries = @ratings.entries(proposal.row)
        rating_count = @ratings.count(proposal.row)
        if rating_count == 0
          div(class: 'others-none') { 'No Ratings' }
        else
          div(class: 'others-head') do
            "Average rating: #{@ratings.average_text(proposal.row)} (#{rating_count})"
          end
          entries.each do |who, value|
            div(class: 'others-row') do
              span(class: 'others-who') { short_name(who) }
              span(class: 'others-score') { value[0] }
              span(class: 'others-comment') { value[1] }
            end
          end
          ''
        end
      else
        div(class: 'others-none') { 'Ratings are shown once you save your own.' }
      end
    end
  end

  def short_name(email)
    email.split('@')[0].to_s
  end

  def speaker_links(proposal)
    parts = []
    parts << "GitHub: #{proposal.github}" unless proposal.github.empty?
    parts << "X: #{proposal.x_account}" unless proposal.x_account.empty?
    parts.join('   ')
  end
end
