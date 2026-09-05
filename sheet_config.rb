class SheetConfig
  SHEETS_KEY = 'cfp_sheets'
  SELECTED_KEY = 'cfp_sheet_id'
  ROW_SEPARATOR = "\n"
  FIELD_SEPARATOR = "\t"

  def self.read(storage, location_hash)
    config = new(storage)
    config.add(location_hash.sub('#', ''))
    config
  end

  attr_reader :sheet_id

  def initialize(storage)
    @storage = storage
    @sheets = [] # localStorage に1行1件、`名前<TAB>ID`の形で持つ。 e.g. "本番\t1AbCdEf\nテスト\t1XyZ123"
    storage.getItem(SHEETS_KEY).to_s.split(ROW_SEPARATOR).each do |line|
      fields = line.split(FIELD_SEPARATOR)
      @sheets << [fields[0].to_s, fields[1].to_s] unless fields[1].to_s.empty?
    end
    @sheet_id = storage.getItem(SELECTED_KEY).to_s
    migrate_single_id
    @sheet_id = first_id unless known?(@sheet_id)
  end

  # ID をひとつだけ保存していた頃の値を一覧に引き継ぐ移行用メソッド
  def migrate_single_id
    @sheets << ['', @sheet_id] if @sheets.empty? && !@sheet_id.empty?
  end

  def sheet_ids = @sheets.map { |sheet| sheet[1] }

  def add(sheet_id)
    return if sheet_id.empty?

    @sheets << ['', sheet_id] unless known?(sheet_id)
    @sheet_id = sheet_id
    save
  end

  def select(sheet_id)
    return unless known?(sheet_id)

    @sheet_id = sheet_id
    save
  end

  def rename(sheet_id, name)
    @sheets.each { |sheet| sheet[0] = clean(name) if sheet[1] == sheet_id }
    save
  end

  def remove(sheet_id)
    @sheets = @sheets.reject { |sheet| sheet[1] == sheet_id }
    @sheet_id = first_id unless known?(@sheet_id)
    save
  end

  def selected?(sheet_id) = @sheet_id == sheet_id

  def name_of(sheet_id)
    found = @sheets.find { |sheet| sheet[1] == sheet_id }
    found.nil? ? '' : found[0]
  end

  def known?(sheet_id) = @sheets.any? { |sheet| sheet[1] == sheet_id }

  def missing? = @sheet_id.empty?

  def first_id = (@sheets.empty? ? '' : @sheets[0][1])

  def clean(name) = name.gsub(FIELD_SEPARATOR, ' ').gsub(ROW_SEPARATOR, ' ')

  def save
    lines = @sheets.map { |sheet| "#{sheet[0]}#{FIELD_SEPARATOR}#{sheet[1]}" }
    @storage.setItem(SHEETS_KEY, lines.join(ROW_SEPARATOR))
    @storage.setItem(SELECTED_KEY, @sheet_id)
  end
end
