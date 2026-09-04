# ブロック: [:heading, レベル, インライン] / [:paragraph, インライン] /
#           [:list, 番号付きか, [インライン, ...]] / [:quote, インライン] / [:code, 文字列]
# インライン: [:text, 文字列] / [:link, ラベル, URL] / [:code, 文字列] / [:strong, 文字列]
class MarkdownParser
  BLANK = /^[ \t]*$/
  HEADING = /^([#]{1,6})[ ]+(.+)$/
  QUOTE = /^>[ ]?(.*)$/
  BULLET = /^[-*][ ]+(.+)$/
  ORDERED = /^[0-9]+\.[ ]+(.+)$/
  FENCE = /^```/

  LINK = /\[([^\]]*)\]\(([^)\s]+)\)/
  STRONG = /\*\*([^*]+)\*\*/
  CODE = /`([^`]+)`/
  URL = %r{https?://[A-Za-z0-9\-._~:/?#\[\]@!$&%'()*+,;=]+}
  TRAILING_CHARS = '.,;:!?)]>'

  def initialize(text)
    @lines = text.split("\n")
  end

  def blocks
    result = []
    index = 0
    while index < @lines.size
      index = parse_block(result, index)
    end
    result
  end

  private

  def parse_block(result, index)
    case @lines[index]
    when BLANK   then index + 1
    when FENCE   then parse_code(result, index)
    when HEADING then parse_heading(result, index)
    when QUOTE   then parse_quote(result, index)
    when BULLET  then parse_list(result, index, ordered: false)
    when ORDERED then parse_list(result, index, ordered: true)
    else parse_paragraph(result, index)
    end
  end

  def parse_heading(result, index)
    found = @lines[index].match(HEADING)
    result << [:heading, "#{found[1]}".size, inline(found[2])]
    index + 1
  end

  def parse_quote(result, index)
    quoted, cursor = collect(index, QUOTE)
    result << [:quote, inline(quoted.join("\n"))]
    cursor
  end

  def parse_list(result, index, ordered:)
    items, cursor = collect(index, ordered ? ORDERED : BULLET)
    result << [:list, ordered, items.map { |item| inline(item) }]
    cursor
  end

  def parse_code(result, index)
    collected = []
    cursor = index + 1
    while cursor < @lines.size
      break if @lines[cursor].match(FENCE)

      collected << @lines[cursor]
      cursor += 1
    end
    result << [:code, collected.join("\n")]
    cursor < @lines.size ? cursor + 1 : cursor
  end

  def parse_paragraph(result, index)
    collected = []
    cursor = index
    while cursor < @lines.size
      break unless paragraph_line?(@lines[cursor])

      collected << @lines[cursor]
      cursor += 1
    end
    result << [:paragraph, inline(collected.join("\n"))]
    cursor
  end

  # どのブロック記法にも当てはまらない行が続く間、ひとつの段落として扱う
  def paragraph_line?(line)
    case line
    when BLANK, FENCE, HEADING, QUOTE, BULLET, ORDERED then false
    else true
    end
  end

  # 同じ記法が続く間、捕獲した中身を集める。
  # @return [Array(Array, Integer)] 捕獲した中身の配列、次の行番号
  def collect(index, pattern)
    collected = []
    cursor = index
    while cursor < @lines.size
      found = @lines[cursor].match(pattern)
      break if found.nil?

      collected << found[1]
      cursor += 1
    end
    [collected, cursor]
  end

  def inline(text)
    nodes = []
    rest = "#{text}"
    while rest.size > 0
      token = earliest_token(rest)
      if token.nil?
        nodes << [:text, rest]
        return nodes
      end

      nodes << [:text, "#{rest[0, token[0]]}"] if token[0] > 0
      nodes << node_for(token)
      rest = "#{rest[token[1], rest.size - token[1]]}"
    end
    nodes
  end

  # 4つの記法をチェックし、最左のものを選ぶ。
  def earliest_token(text)
    earliest = earlier_token(nil, text.match(LINK), :link)
    earliest = earlier_token(earliest, text.match(CODE), :code)
    earliest = earlier_token(earliest, text.match(STRONG), :strong)
    earlier_token(earliest, text.match(URL), :url)
  end

  # @return [Array(Integer, Integer, Symbol, MatchData)] 開始位置、終了位置、種類、MatchData
  def earlier_token(earliest, found, kind)
    return earliest if found.nil?

    offset = found.begin(0)
    return earliest unless earliest.nil? || offset < earliest[0]

    finish = kind == :url ? offset + trim_trailing(found[0]) : found.end(0)
    [offset, finish, kind, found]
  end

  def node_for(token)
    found = token[3]
    case token[2]
    when :link   then [:link, found[1], found[2]]
    when :code   then [:code, found[1]]
    when :strong then [:strong, found[1]]
    else
      url = "#{found[0][0, trim_trailing(found[0])]}"
      [:link, url, url]
    end
  end

  # 末尾の句読点を除いた長さを返す。文字数だけ数えてスライスはしない。
  def trim_trailing(url)
    length = url.size
    while length > 1
      break unless TRAILING_CHARS.include?(url[length - 1, 1])

      length -= 1
    end
    length
  end
end
