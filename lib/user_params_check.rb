class UserParamsCheck
  def initialize(app)
    @app = app
    @check_params = ['email', 'login']
  end

  def call(env)
    params = env['rack.request.form_hash']
    if env['REQUEST_METHOD'] == 'POST' && params && params['user'].kind_of?(Hash) && !params['user']['_check'].nil?
      user_params = params['user']
      @check_params.each do |param|
        next unless user_params.key?(param)
        if user_params[param].blank?
          user_params[param] = user_params['_check']
          user_params.delete('_check')
          break
        else
          return [301, {"Location" => env['HTTP_REFERER'] }, [] ]
        end
      end
    end

    @app.call(env)
  end
end