class Session
  attr_reader :token, :email

  def initialize
    @token = ''
    @email = ''
  end

  def token=(value)
    @token = value.to_s
  end

  def signed_in? = !@token.empty?
  def identified? = !@email.empty?

  def identify
    @email = SheetsClient.my_email(@token)
  end
end
