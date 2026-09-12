class States
  SUBMITTED = 'submitted'
  SOFT_ACCEPTED = 'soft accepted'
  SOFT_WAITLISTED = 'soft waitlisted'
  SOFT_REJECTED = 'soft rejected'
  ACCEPTED = 'accepted'
  WAITLISTED = 'waitlisted'
  REJECTED = 'rejected'
  NOT_ACCEPTED = 'not accepted'

  FINAL_OF = {
    SOFT_ACCEPTED => ACCEPTED,
    SOFT_WAITLISTED => WAITLISTED,
    SOFT_REJECTED => REJECTED
  }.freeze

  SOFT = [SOFT_ACCEPTED, SOFT_WAITLISTED, SOFT_REJECTED].freeze
  FINAL = [ACCEPTED, WAITLISTED, REJECTED].freeze
  ALL = [SUBMITTED, SOFT_ACCEPTED, SOFT_WAITLISTED, SOFT_REJECTED,
         ACCEPTED, WAITLISTED, REJECTED].freeze

  ORDER = {
    ACCEPTED => 0, SOFT_ACCEPTED => 1,
    WAITLISTED => 2, SOFT_WAITLISTED => 3,
    REJECTED => 4, SOFT_REJECTED => 5,
    SUBMITTED => 6
  }.freeze

  LABEL_CLASS = {
    ACCEPTED => 'label-success', SOFT_ACCEPTED => 'label-success',
    WAITLISTED => 'label-warning', SOFT_WAITLISTED => 'label-warning',
    REJECTED => 'label-danger', SOFT_REJECTED => 'label-danger'
  }.freeze

  class << self
    def label_of(state) = (state == REJECTED ? NOT_ACCEPTED : state)
  end

  # 列: A タイムスタンプ / B 採択者 / C 対象の行番号 / D 状態
  def initialize(rows)
    @by_row = {}
    rows.each do |row|
      row_number = row[2].to_s.to_i
      next if row_number == 0

      @by_row[row_number] = row[3].to_s
    end
  end

  def of(row)
    found = @by_row[row]
    found.nil? || found.empty? ? SUBMITTED : found
  end

  def record(row, state) = @by_row[row] = state

  def label(row) = States.label_of(of(row))

  def label_class(row)
    found = LABEL_CLASS[of(row)]
    found.nil? ? 'label-default' : found
  end

  def submitted?(row) = of(row) == SUBMITTED
  def soft?(row) = SOFT.include?(of(row))
  def finalized?(row) = FINAL.include?(of(row))
  def final_of(row) = FINAL_OF[of(row)]
  def accepted?(row) = of(row) == ACCEPTED

  def order(row)
    found = ORDER[of(row)]
    found.nil? ? ORDER.size : found
  end
end
