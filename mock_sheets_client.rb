module SheetsClient
  TALK = 'Talk Session(20min固定)'
  SHOWCASE = 'Showcase Session'

  # 行番号は Proposals::TEST_ROWS([2, 3, 4, 7]) と噛み合わせてある。
  # 2,3,4,7 がテスト投稿、9 行目がレビュアー自身の投稿。
  FAKE = [
    ['2026/06/24 19:50', 't@example.com', 'テストタイトル', TALK,
     'test', 'test', '', '', 'テスト', '', '', ''],
    ['2026/06/25 21:28', 't@example.com', 'テストトーク', TALK,
     'test', 'test', '', '', 'テスト', '', '', ''],
    ['2026/06/25 22:05', 't@example.com', 'テストタイトル', SHOWCASE,
     'test', 'test', '', '', 'テスト', '', '', ''],
    ['2026/07/01 10:00', 'a@example.com', 'PicoRuby でトースターを焼く', TALK,
     'マイコンで温度制御をするときの、Ruby らしい書き方の話です。',
     "PID 制御を Ruby で書くと、係数の調整がそのままコードの読みやすさに出ます。\n\n" \
     "前半では素朴な実装から始めて、後半でヒープの使い方を詰めていきます。\n" \
     '実機のデモを交えます。',
     'トースターは誰の家にもあるので、聞いた人がその日から真似できます。',
     '実機を持ち込みます', '田中 花子', '組み込み Ruby を書いています',
     'tanaka', 'tanaka_h'],
    ['2026/07/02 12:30', 'b@example.com', 'mruby/c のスケジューラを読む', TALK,
     'タスクスケジューラの実装を1行ずつ追いかけます。',
     "コンテキストスイッチがどこで起きているかを、実際のコードで確かめます。\n" \
     'wasm 版でも同じ仕組みが動いていることを見ます。',
     '内部を知ると、詰まったときの勘が働くようになります。',
     '', '鈴木 太郎', 'RTOS まわりが好きです', 'suzuki', ''],
    ['2026/07/03 22:17', 't@example.com', 'テスト4件目', SHOWCASE,
     'test', 'test', '', '', 'テスト', '', '', ''],
    ['2026/07/05 09:15', 'c@example.com', 'LED を光らせるだけの15分', SHOWCASE,
     'ひたすら光らせます。',
     "配線から書き込みまでを、その場で最初からやります。\n" \
     '初めての人が持ち帰れる最小構成を目指します。',
     '', 'ボードを配ります', '佐藤 次郎', '', '', 'sato_j'],
    ['2026/07/06 22:40', 'reviewer@example.com', 'ブレッドボードの上の Ruby', SHOWCASE,
     '短い Abstract。',
     "Abstract は短いが Details は長い、という投稿の見え方を確かめるための行。\n" \
     '本文はしっかりある。', '', '', '高橋 三郎', '', '', '']
  ]

  class << self
    def my_email(_token)
      'reviewer@example.com'
    end

    def ratings_store
      $mock_ratings ||= [
        ['2026-08-30T01:00:00.000Z', 'alice@example.com', '5', '5', 'ぜひ聞きたい'],
        ['2026-08-30T02:00:00.000Z', 'bob@example.com',   '5', '4', 'デモの完成度次第'],
        ['2026-08-30T03:00:00.000Z', 'alice@example.com', '6', '3', ''],
        ['2026-08-30T04:00:00.000Z', 'bob@example.com',   '5', '3', '前言撤回。尺が足りないかも'],
        ['2026-08-30T05:00:00.000Z', 'alice@example.com', '9', '4', '本人には見せないコメント'],
        ['2026-08-30T06:00:00.000Z', 'bob@example.com',   '9', '2', 'これも見せない']
      ]
    end

    def get_values(_token, _sheet_id, range)
      rows = range == 'Ratings!A2:E' ? ratings_store : FAKE
      [200, { values: rows }]
    end

    def append(_token, _sheet_id, _range, cells)
      ratings_store << cells
      [200, nil]
    end

    def to_rows(values)
      values.nil? ? [] : values
    end

    def error_message(_body)
      ''
    end
  end
end
