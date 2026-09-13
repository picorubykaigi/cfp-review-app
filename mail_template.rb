class MailTemplate
  STATES = [States::ACCEPTED, States::REJECTED].freeze
  PATHS = {
    States::ACCEPTED => 'mails/accepted.txt',
    States::REJECTED => 'mails/not_accepted.txt'
  }.freeze
  BODY_INDEX = 2
  FORMATS = %w[Talk Showcase].freeze

  # textは以下の形式:
  #   1行目: 件名
  #   3行目以降: 本文
  def initialize(text, proposal)
    @lines = text.split("\n")
    @proposal = proposal
  end

  def subject = @lines[0].to_s

  def body = body_lines.join("\n")

  def body_lines
    out = []
    open_format = nil
    @lines[BODY_INDEX, @lines.size].each do |line|
      if open_format.nil?
        open_format = take(line, out)
      else
        open_format = continue(line, out, open_format)
      end
    end
    out
  end

  # `{Talk:}``{Showcase:}` で始まる行は対象発表スタイルのときだけ前置きを外して残す
  # 複数行のときは `{Showcase:` で始まり、最後の行が `}` で終わる
  def take(line, out)
    format = FORMATS.find { |name| line.start_with?("{#{name}:") }
    if format.nil?
      out << fill(line)
      nil
    elsif line.start_with?("{#{format}:}")
      out << fill(line.delete_prefix("{#{format}:}")) if format == @proposal.format_label
      nil
    else
      format
    end
  end

  def continue(line, out, format)
    closing = line.end_with?('}')
    body = closing ? line[0, line.size - 1] : line
    out << fill(body) if format == @proposal.format_label
    closing ? nil : format
  end

  def fill(line)
    line.gsub(/\{Title:\}/) { @proposal.title }
      .gsub(/\{Talk or Showcase:\}/) { @proposal.format_label }
  end
end
