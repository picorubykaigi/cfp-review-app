class Tags
  SEPARATOR = ','
  BLANKS = [' ', "\t", "\n", "\r"].freeze

  # 回答シートの列（Googleフォームの項目順。1行目はヘッダなので2行目から）:
  #   A タイムスタンプ / B 編集した人 / C 対象の行番号 / D タグ（カンマ区切り）
  # append のみで、行番号ごとに最後の行がいまのタグ。
  def initialize(rows)
    @by_row = {}
    rows.each do |row|
      row_number = row[2].to_s.to_i
      next if row_number == 0

      @by_row[row_number] = parse(row[3].to_s)
    end
  end

  def of(row)
    found = @by_row[row]
    found.nil? ? [] : found
  end

  def text(row) = to_text(of(row))

  def record(row, list) = @by_row[row] = list

  def all
    names = []
    @by_row.each { |_row, list| list.each { |tag| names << tag unless names.include?(tag) } }
    names.sort
  end

  # e.g. 'b, a, , a' -> ['a', 'b']
  def parse(text)
    list = []
    start = 0
    index = 0
    size = text.size
    while index <= size
      if index == size || text[index, 1] == SEPARATOR
        name = trimmed(text, start, index)
        list << name unless name.nil? || list.include?(name)
        start = index + 1
      end
      index += 1
    end
    list.sort
  end

  # text の from...to を前後の空白を落として返す。空なら nil。
  def trimmed(text, from, to)
    from += 1 while from < to && blank?(text[from, 1])
    to -= 1 while to > from && blank?(text[to - 1, 1])
    from < to ? text[from, to - from] : nil
  end

  def blank?(char) = BLANKS.include?(char)

  def to_text(list) = list.join(', ')
end
