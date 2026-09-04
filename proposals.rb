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
      order = compare(left, right, key, desc, ratings)
      order == 0 ? (left.row <=> right.row) : order
    end)
  end

  def compare(left, right, key, desc, ratings)
    case key
    when 'ratings'
      compare_count(left, right, desc, ratings)
    when 'standard_deviation'
      compare_visible(left, right, desc, ratings) do
        ratings.standard_deviation(left.row) <=> ratings.standard_deviation(right.row)
      end
    when 'title'
      flip(left.title <=> right.title, desc)
    when 'speaker'
      flip(left.name <=> right.name, desc)
    when 'format'
      flip(left.format_label <=> right.format_label, desc)
    else # score, reset
      compare_visible(left, right, desc, ratings) do
        ratings.average(left.row) <=> ratings.average(right.row)
      end
    end
  end

  def compare_count(left, right, desc, ratings)
    order = flip(ratings.count(left.row) <=> ratings.count(right.row), desc)
    # 人数が同数のときは timestamp 順
    order == 0 ? newest_first(left, right) : order
  end

  def compare_visible(left, right, desc, ratings)
    left_hidden = !ratings.scores_visible?(left)
    right_hidden = !ratings.scores_visible?(right)
    if left_hidden && right_hidden
      newest_first(left, right)
    elsif left_hidden != right_hidden
      flip(left_hidden ? -1 : 1, desc)
    else
      flip(yield, desc)
    end
  end

  def newest_first(left, right) = (right.timestamp <=> left.timestamp)

  def flip(order, desc) = (desc ? -order : order)

  def matches?(text, query)
    return true if query.empty?

    text.downcase.include?(query.downcase)
  end
end
