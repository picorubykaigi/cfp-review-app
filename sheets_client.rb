require 'js'

# Sheets API v4 の薄いクライアント。
# fetch はブロック必須で、ブロックは呼び出しの後続行より先に走る。
module SheetsClient
  BASE = 'https://sheets.googleapis.com/v4/spreadsheets'

  class << self
    # [status, body(JS::Object or nil)] を返す。例外は投げない。
    def request(url, opts)
      out = nil
      JS.global.fetch(url, opts) do |resp|
        status = resp[:status].to_s.to_i
        body = nil
        begin
          body = resp.json.await
        rescue
          body = nil
        end
        out = [status, body]
      end
      out.nil? ? [0, nil] : out
    end

    def enc(s)
      JS.global.encodeURIComponent(s).to_s
    end

    # fetch の第2引数は Ruby の Hash で渡す。JS オブジェクトを渡すと
    # picoruby が JSON に変換できず TypeError になり、なおかつ Ruby のタスクが
    # 戻ってこなくなる（ブラウザごと固まる）。
    def get_opts(token)
      { 'method' => 'GET',
        'headers' => { 'Authorization' => "Bearer #{token}" } }
    end

    def post_opts(token, body)
      { 'method' => 'POST',
        'headers' => { 'Authorization' => "Bearer #{token}",
                       'Content-Type' => 'application/json' },
        'body' => body }
    end

    def get_values(token, sheet_id, range)
      url = "#{BASE}/#{enc(sheet_id)}/values/#{enc(range)}"
      request(url, get_opts(token))
    end

    def append(token, sheet_id, range, cells)
      url = "#{BASE}/#{enc(sheet_id)}/values/#{enc(range)}:append" \
            '?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS'
      request(url, post_opts(token, JSON.generate(values: [cells])))
    end

    def my_email(token)
      url = 'https://www.googleapis.com/oauth2/v3/userinfo'
      status, body = request(url, get_opts(token))
      return '' unless status == 200 && body
      value = body[:email]
      value.nil? ? '' : value.to_s
    end

    # JS の二次元配列を Ruby の Array<Array<String>> にする。
    # Sheets API は行末の空セルを省くので、行ごとに長さが違う。
    def to_rows(values)
      return [] if values.nil?
      row_count = values[:length].to_s.to_i
      rows = []
      row_index = 0
      while row_index < row_count
        row = values[row_index]
        cells = []
        unless row.nil?
          cell_count = row[:length].to_s.to_i
          cell_index = 0
          while cell_index < cell_count
            value = row[cell_index]
            cells << (value.nil? ? '' : value.to_s)
            cell_index += 1
          end
        end
        rows << cells
        row_index += 1
      end
      rows
    end

    def error_message(body)
      return '' if body.nil?

      error = body[:error]
      return '' if error.nil?

      message = error[:message]
      message.nil? ? '' : message.to_s
    end
  end
end
