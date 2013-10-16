
class UserParamsCheck
  def initialize(app)
    @app = app
    @check_params = ['email', 'login']
  end

  def call(env)
    params = env['rack.request.form_hash']
    if params && params['user'] && params['user']['check'] && env['REQUEST_METHOD'] == 'POST'
      @check_params.each do |param|
        if params['user'].key?(param)
          if params['user'][param].blank?
            params['user'][param] = params['user']['check']
            params['user'].delete('check')
            env['rack.request.form_hash'] = params
            return @app.call(env)
          else
            return [301, {"Location" => env['REQUEST_PATH'] }, [] ]
          end
        end
      end
    else
      @app.call(env)
    end
  end
end