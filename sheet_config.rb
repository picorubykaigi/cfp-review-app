class SheetConfig
  KEY = 'cfp_sheet_id'

  def self.read(storage, location_hash)
    sheet_id = location_hash.sub('#', '')
    return new(storage.getItem(KEY).to_s) if sheet_id.empty?

    storage.setItem(KEY, sheet_id)
    new(sheet_id)
  end

  attr_reader :sheet_id

  def initialize(sheet_id)
    @sheet_id = sheet_id
  end

  def missing? = @sheet_id.empty?
end
