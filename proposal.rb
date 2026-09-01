class Proposal
  TALK = 'Talk Session(20min固定)'
  SHOWCASE = 'Showcase Session'

  attr_reader :row, :timestamp, :email, :title, :format, :abstract,
              :details, :pitch, :demo, :name, :bio, :github, :x_account

  # cells は A列から順に並んだ文字列の配列。row はシート上の行番号。
  # 回答シートの列（Googleフォームの項目順。1行目はヘッダなので2行目から）:
  #
  #   A タイムスタンプ      G Pitch
  #   B メールアドレス      H Demo details
  #   C Title               I Your name
  #   D Session format      J Speaker Bio
  #   E Abstract            K GitHub account
  #   F Details             L X account
  def initialize(row, cells)
    @row = row
    @timestamp = at(cells, 0)
    @email     = at(cells, 1)
    @title     = at(cells, 2)
    @format    = at(cells, 3)
    @abstract  = at(cells, 4)
    @details   = at(cells, 5)
    @pitch     = at(cells, 6)
    @demo      = at(cells, 7)
    @name      = at(cells, 8)
    @bio       = at(cells, 9)
    @github    = at(cells, 10)
    @x_account = at(cells, 11)
  end

  def at(cells, i)
    value = cells[i]
    value.nil? ? '' : value
  end

  def format_label = (talk? ? 'Talk' : 'Showcase')

  def talk? = @format == TALK
end
