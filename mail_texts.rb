class MailTexts
  # 列: A 状態 / B 件名 / C 本文
  def initialize(rows)
    @by_status = {}
    rows.each do |row|
      status = row[0].to_s
      @by_status[status] = [row[1].to_s, row[2].to_s] unless status.empty?
    end
  end

  def subject_of(status) = of(status)[0]
  def body_of(status) = of(status)[1]
  def exists?(status) = !body_of(status).empty?

  private

  def of(status)
    found = @by_status[status]
    found.nil? ? ['', ''] : found
  end
end
