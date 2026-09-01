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
          'このツールが実際に読むのは CFP の回答シート1件のみです。'
        end
      end
      button(class: 'btn btn-primary', onclick: :sign_in) do
        state.busy ? 'サインイン中…' : 'Google でサインイン'
      end
      div(class: 'err') { state.message }
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
      button(class: 'btn btn-primary', onclick: :sign_in) { 'やり直す' }
    end
  end
end
