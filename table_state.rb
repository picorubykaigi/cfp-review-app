class TableState
  SORT_KEY = 'cfp_table_sort'
  DESC_KEY = 'cfp_table_desc'
  UNSORTED = ''
  TEXT_COLUMNS = %w[title speaker format tags].freeze

  attr_reader :sort, :desc
  attr_writer :speaker, :title, :format, :tag

  def initialize(storage)
    @storage = storage
    @sort = UNSORTED
    @desc = false
    @speaker = ''
    @title = ''
    @format = ''
    @tag = ''
    restore
  end

  def apply(proposals, ratings, tags)
    proposals.matching(@speaker, @title, @format)
      .tagged(@tag, tags)
      .sorted(@sort, @desc, ratings, tags)
  end

  # 同じ列を再度押したら向きを変える。別の列なら、数値の列は降順、文字の列は昇順にソートする。
  def sort_by(key)
    if @sort == key
      @desc = !@desc
    else
      @sort = key
      @desc = !TEXT_COLUMNS.include?(key)
    end
    save
  end

  def reset
    @sort = UNSORTED
    @desc = false
    @storage.removeItem(SORT_KEY)
    @storage.removeItem(DESC_KEY)
  end

  def marker(key)
    return '' unless @sort == key

    @desc ? ' ▼' : ' ▲'
  end

  def restore
    key = @storage.getItem(SORT_KEY).to_s
    return if key.empty?

    @sort = key
    @desc = @storage.getItem(DESC_KEY).to_s == '1'
  end

  def save
    @storage.setItem(SORT_KEY, @sort)
    @storage.setItem(DESC_KEY, @desc ? '1' : '0')
  end
end
