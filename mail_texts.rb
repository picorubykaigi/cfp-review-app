class MailTexts
  # 列: A 名前 / B 件名 / C 本文
  def initialize(rows)
    @names = []
    @by_name = {}
    rows.each do |row|
      name = row[0].to_s
      next if name.empty? || @by_name.key?(name)

      @names << name
      @by_name[name] = [row[1].to_s, row[2].to_s]
    end
  end

  attr_reader :names

  def empty? = @names.empty?
  def subject_of(name) = of(name)[0]
  def body_of(name) = of(name)[1]

  private

  def of(name)
    found = @by_name[name]
    found.nil? ? ['', ''] : found
  end
end
