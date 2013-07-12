class Smsc
  attr_accessor :user, :password, :json
  
  attr_accessor :data, :url
  
  attr_reader :error, :error_message
  
  def initialize(user, password, json = true)
    @user, @password, @json = user.strip, password.strip, json
    @data = {'user' => @user, 'password' => self.md5_password}
    @data = @data.merge({'answer' => 'json'}) if @json
    @error = false
    @url = 'http://gate.smsaero.ru/'
  end
  
  ### Передача сообщения
  def send to, text, from, date = nil
    
  end

  ### Проверка состояния отправленного сообщения
  def status sms_id
    
  end
  
  ### Проверка состояния счета
  def balance
    
  end
  
  ### Список доступных подписей отправителя
  def signatures
    
  end
  
  ### Добавляем новую подпись
  # подпись будет добавлена после ее подтверждения в смс-центре
  def add_signature signature
    
  end
  
  def send_query path
    response = JSON.parse(open(path).read)
    if response['result'].present?
      if response['result'] == 'reject'
        @error_message = self.auth_error(response)
        @error = true
        return false
      end
    end
    response
  end
  
  def md5_password
    Digest::MD5.hexdigest(self.password)
  end
  
  def send_message response
    
  end
  
  def status_message response
    
  end
  
  def auth_error response
    
  end
  
  def error
    {
      status: @error,
      message: @error_message
    }
  end
end