module Signin
  def render_signin
    div(class: 'gate') do
      h2 { 'PicoRubyKaigi 2026 Assemble CFP Review App' }
      div(class: 'notice') do
        div(class: 'notice-head') do
          '初回だけ「このアプリは Google で確認されていません」と表示されます。'
        end
        div(class: 'notice-body') do
          '「詳細」→「(アプリ名) に移動」と進んでください。'
        end
        div(class: 'notice-body') do
          '求められる権限は、あなたがアクセスできるスプレッドシートの読み書きです。' \
          'このツールが実際に読み書きするのは、選択したスプレッドシート 1 件のみです。'
        end
      end
      render_sheet_picker
      button(class: 'btn btn-primary', onclick: :sign_in) do
        state.busy ? 'サインイン中…' : 'Google でサインイン'
      end
      div(class: 'err') { state.message }
    end
  end

  def render_sheet_picker
    return '' if @config.sheet_ids.empty?

    div(class: 'sheets') do
      div(class: 'sheets-head') { 'スプレッドシート' }
      @config.sheet_ids.each { |sheet_id| render_sheet_row(sheet_id) }
      div(class: 'sheets-hint') { 'URL の末尾に #シートID を付けて開くと追加されます。' }
    end
  end

  def render_sheet_row(sheet_id)
    editing = state.editing == sheet_id
    div(class: 'sheet-row') do
      input(type: 'radio', name: 'cfp-sheet', class: 'sheet-pick',
            checked: @config.selected?(sheet_id),
            onchange: ->(*_a) { select_sheet(sheet_id) })
      div(class: 'sheet-body') do
        editing ? render_sheet_name_input(sheet_id) : render_sheet_name(sheet_id)
        div(class: 'sheet-id') { sheet_id }
      end
      render_sheet_edit_button(sheet_id, editing)
      button(class: 'btn btn-default btn-sm btn-icon',
             onclick: ->(*_a) { remove_sheet(sheet_id) }) { '🗑' }
    end
  end

  def render_sheet_name(sheet_id)
    name = @config.name_of(sheet_id)
    div(class: name.empty? ? 'sheet-label sheet-label-none' : 'sheet-label') do
      name.empty? ? '名前なし' : name
    end
  end

  def render_sheet_name_input(sheet_id)
    input(type: 'text', class: 'sheet-name', id: "sheet-name-#{sheet_id}",
          value: @config.name_of(sheet_id), placeholder: '名前')
  end

  def render_sheet_edit_button(sheet_id, editing)
    if editing
      button(class: 'btn btn-primary btn-sm btn-icon',
             onclick: ->(*_a) { save_sheet_name(sheet_id) }) { '✓' }
    else
      button(class: 'btn btn-default btn-sm btn-icon',
             onclick: ->(*_a) { edit_sheet(sheet_id) }) { '✎' }
    end
  end

  def render_setup
    div(class: 'gate') do
      h2 { 'セットアップが必要です' }
      div(class: 'notice-body') do
        'config.js の CFP_CLIENT_ID が空です。Google Cloud で OAuth クライアントID' \
        '（ウェブアプリケーション）を作り、承認済み JavaScript 生成元にこのページの' \
        'オリジンを登録したうえで、その値を config.js に貼ってください。'
      end
    end
  end

  def render_nosheet
    div(class: 'gate') do
      h2 { 'シートIDが指定されていません' }
      div(class: 'notice-body') do
        'URL の末尾に #スプレッドシートID を付けて開いてください。'
      end
    end
  end

  def render_error
    div(class: 'gate') do
      h2 { '読み込めませんでした' }
      div(class: 'err') { state.message }
      render_sheet_picker
      button(class: 'btn btn-primary', onclick: :sign_in) { 'やり直す' }
    end
  end
end
