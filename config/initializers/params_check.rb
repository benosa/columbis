class ParamsCheck
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    response.body += "\nHi from #{self.class}"
    # response.body << "..." WILL NOT WORK
    [status, headers, response]
  end
end