class MailTexts
  def initialize
    @texts = {}
  end

  def load
    MailTemplate::PATHS.each do |status, path|
      @texts[status] = read(path) if @texts[status].nil?
    end
  end

  def of(status) = @texts[status].to_s
  def exists?(status) = !of(status).empty?

  private

  def read(path)
    out = ''
    JS.global.fetch(path, { 'cache' => 'no-store' }) do |response|
      out = response.text.await.to_s if response[:status].to_s.to_i == 200
    end
    out
  end
end
