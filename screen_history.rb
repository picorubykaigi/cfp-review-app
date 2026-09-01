class ScreenHistory
  def initialize
    @stack = []
  end

  def empty? = @stack.empty?
  def pop = @stack.pop

  def push(phase)
    @stack << phase
    JS.global.cfpPushState
  end

  def back = JS.global.cfpBack
end
