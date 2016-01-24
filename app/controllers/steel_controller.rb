class SteelController < ActionController::Metal

  def hey
    self.response_body = "hey before filter."
  end

  def index
    self.response_body = "Hello World!"
  end
end