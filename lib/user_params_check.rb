class UserParamsCheck
  def initialize(app)
    @app = app
    @check_params = ['email', 'login']
  end

  def call(env)
    params = env['rack.request.form_hash']
    if env['REQUEST_METHOD'] == 'POST' && params && params['user'] && params['user']['_check']
      @check_params.each do |param|
        if params['user'].key?(param)
          if params['user'][param].blank?
            params['user'][param] = params['user']['_check']
            params['user'].delete('_check')
            env['rack.request.form_hash'] = params
            return @app.call(env)
          else
            return [301, {"Location" => env['HTTP_REFERER'] }, [] ]
          end
        end
      end
    else
      @app.call(env)
    end
  end
end