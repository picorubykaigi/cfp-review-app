class Ratings
  UNRATED = -1.0

  # 列は A タイムスタンプ / B レビュアー / C 対象の行番号 / D 点数 / E コメント。
  # append のみで最新が勝つ。
  def initialize(rows, me)
    @me = me
    @by_row = {}
    rows.each do |row|
      row_number = row[2].to_s.to_i
      next if row_number == 0

      @by_row[row_number] = {} if @by_row[row_number].nil?
      @by_row[row_number][row[1].to_s] = [row[3].to_s, row[4].to_s]
    end
  end

  # 行番号 => { メールアドレス => [点数, コメント] }
  def entries(row) = @by_row[row]

  def record(row, email, score, comment)
    @by_row[row] = {} if @by_row[row].nil?
    @by_row[row][email] = [score, comment]
  end

  def mine(row)
    found = @by_row[row]
    found.nil? ? nil : found[@me]
  end

  def rated?(row) = !mine(row).nil?
  def count(row) = scores(row).size

  def average(row)
    list = scores(row)
    return UNRATED if list.empty?

    total(list).fdiv(list.size)
  end

  def standard_deviation(row)
    list = scores(row)
    return UNRATED if list.size < 2

    mean = total(list).fdiv(list.size)
    squared = list.map { |score| (score - mean) * (score - mean) }
    Math.sqrt(total(squared).fdiv(list.size))
  end

  def average_text(row) = to_text(average(row))
  def standard_deviation_text(row) = to_text(standard_deviation(row))

  def scores(row)
    found = @by_row[row]
    return [] if found.nil?

    found.values.map { |value| value[0].to_f }.reject { |score| score <= 0 }
  end

  def to_text(value) = (value == UNRATED ? '' : value.round(1).to_s)

  def total(list) = list.inject(0) { |sum, value| sum + value }
end
