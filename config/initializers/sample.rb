# Fake Middleware...doesn't do anything.
module Sample
  
  class Middleware
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    end

  end
end