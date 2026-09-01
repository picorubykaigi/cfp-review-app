class Proposals
  FIRST_DATA_ROW = 2
  TEST_ROWS = [2, 3, 4, 7].freeze

  def self.build(rows)
    list = []
    rows.each_with_index do |cells, index|
      row_number = FIRST_DATA_ROW + index
      list << Proposal.new(row_number, cells) unless TEST_ROWS.include?(row_number)
    end
    new(list)
  end

  def initialize(list)
    @list = list
  end

  def size = @list.size
  def empty? = @list.empty?
  def [](index) = @list[index]
  def each = @list.each { |proposal| yield proposal }
  def each_with_index = @list.each_with_index { |proposal, index| yield proposal, index }

  def matching(speaker, title, format)
    Proposals.new(@list.select do |proposal|
      matches?(proposal.name, speaker) &&
        matches?(proposal.title, title) &&
        matches?(proposal.format_label, format)
    end)
  end

  def sorted(key, desc, ratings)
    Proposals.new(@list.sort do |left, right|
      order = compare(left, right, key, ratings)
      order = -order if desc
      order == 0 ? (left.row <=> right.row) : order
    end)
  end

  def compare(left, right, key, ratings)
    case key
    when 'ratings'
      ratings.count(left.row) <=> ratings.count(right.row)
    when 'standard_deviation'
      ratings.standard_deviation(left.row) <=> ratings.standard_deviation(right.row)
    when 'title'
      left.title <=> right.title
    when 'speaker'
      left.name <=> right.name
    when 'format'
      left.format_label <=> right.format_label
    else
      ratings.average(left.row) <=> ratings.average(right.row)
    end
  end

  def matches?(text, query)
    return true if query.empty?

    text.downcase.include?(query.downcase)
  end
end
