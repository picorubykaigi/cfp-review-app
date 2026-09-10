# トークン: [種類, 文字列]
# 種類: :text / :comment / :string / :symbol / :number / :keyword /
#       :builtin / :constant / :function / :variable
class SyntaxHighlighter
  RUBY_NAMES = %w[ruby rb]

  # prism では IDENTIFIER で返るが、色を分けたい語
  RUBY_BUILTINS = %w[
    attr_accessor attr_reader attr_writer extend include lambda loop new
    p print proc puts raise require require_relative
  ]

  # 引用符付きシンボル（:"a"）も文字列と同じ色なので、開き閉じを追わずに済ませる
  PRISM_STRINGS = %w[
    STRING_BEGIN STRING_CONTENT STRING_END LABEL_END CHARACTER_LITERAL
    HEREDOC_START HEREDOC_END REGEXP_BEGIN REGEXP_END
    EMBEXPR_BEGIN EMBEXPR_END EMBVAR
    PERCENT_LOWER_W PERCENT_UPPER_W PERCENT_LOWER_I PERCENT_UPPER_I
    PERCENT_LOWER_X WORDS_SEP
  ]
  PRISM_VARIABLES = %w[
    INSTANCE_VARIABLE CLASS_VARIABLE GLOBAL_VARIABLE
    BACK_REFERENCE NUMBERED_REFERENCE
  ]
  PRISM_NUMBERS = %w[INTEGER FLOAT RATIONAL IMAGINARY]

  def initialize(code, language)
    @code = code
    @ruby = ruby?(language)
    @expect_symbol_name = false
    @expect_method_name = false
  end

  def tokens
    if @ruby && JS.global[:prismReady]
      ruby_tokens
    else
      [[:text, @code]]
    end
  end

  private

  # ``` だけで言語を書いていないものは Ruby として読む
  def ruby?(language)
    language.size == 0 || RUBY_NAMES.include?(language)
  end

  # 例外を投げるとタスクごと黙って死ぬので、色を諦め素のまま返す
  def ruby_tokens
    build_tokens(JS.global.lexPrism(@code))
  rescue StandardError
    [[:text, @code]]
  end

  # prism が飛ばした範囲（空白など）は自分で埋める
  def build_tokens(found)
    result = []
    last = 0
    index = 0
    count = found[:length].to_i
    while index < count
      token = found[index]
      type = "#{token[:type]}"
      if type == 'EOF'
        index = count
      else
        start = token[:startOffset].to_i
        finish = start + token[:length].to_i
        text = slice(start, finish)
        result << [:text, slice(last, start)] if start > last
        result << [prism_kind(type, text), text]
        last = finish
        index += 1
      end
    end
    result << [:text, slice(last, @code.bytesize)] if last < @code.bytesize
    result
  end

  # prism が返すのはバイトでの位置。String#slice は文字単位なので使えない
  def slice(start, finish)
    "#{@code.byteslice(start, finish - start)}"
  end

  def prism_kind(type, text)
    if @expect_symbol_name
      @expect_symbol_name = false
      :symbol
    else
      case type
      when 'COMMENT' then :comment
      when 'CONSTANT' then :constant
      when 'LABEL' then :symbol
      when 'IDENTIFIER' then identifier_kind(text)
      when 'METHOD_NAME' then method_name_kind
      when 'SYMBOL_BEGIN' then symbol_begin_kind(text)
      when 'KEYWORD_DEF' then keyword_def_kind
      when *PRISM_STRINGS then :string
      when *PRISM_VARIABLES then :variable
      when *PRISM_NUMBERS then :number
      else type.start_with?('KEYWORD_') ? :keyword : :text
      end
    end
  end

  def identifier_kind(text)
    if @expect_method_name
      @expect_method_name = false
      :function
    elsif RUBY_BUILTINS.include?(text)
      :builtin
    else
      :text
    end
  end

  def method_name_kind
    @expect_method_name = false
    :function
  end

  # :foo は SYMBOL_BEGIN が : だけで返り、名前は次のトークンに分かれている
  def symbol_begin_kind(text)
    @expect_symbol_name = true if text == ':'
    :symbol
  end

  def keyword_def_kind
    @expect_method_name = true
    :keyword
  end
end
