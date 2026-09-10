# URL のハッシュ: `#<シートID>` または `#/<行番号>`
class Permalink
  PREFIX = '#/'

  class << self
    def sheet_id(location_hash)
      if proposal?(location_hash)
        ''
      else
        location_hash.sub('#', '')
      end
    end

    def row(location_hash)
      if proposal?(location_hash)
        location_hash.sub(PREFIX, '').to_i
      else
        nil
      end
    end

    def show(row)
      JS.global[:location][:hash] = "#{PREFIX}#{row}"
    end

    def clear = JS.global.cfpDropHash

    private

    def proposal?(location_hash) = location_hash.start_with?(PREFIX)
  end
end
