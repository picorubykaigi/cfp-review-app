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
    @lines[BODY_INDEX, @lines.size].map { |line| keep(line) }.compact
  end

  # `{Talk:}``{Showcase:}` で始まる行は対象発表スタイルのときだけ前置きを外して残す
  def keep(line)
    format = FORMATS.find { |format| line.start_with?("{#{format}:}") }
    if format.nil?
      fill(line)
    elsif format == @proposal.format_label
      fill(line.delete_prefix("{#{format}:}"))
    end
  end

  def fill(line)
    line.gsub(/\{Title:\}/) { @proposal.title }
      .gsub(/\{Talk or Showcase:\}/) { @proposal.format_label }
  end
end
