class Smsaero
  attr_accessor :login, :password, :json
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
  #
  # user......Обязательно  Логин в системе
  # password..Обязательно  Пароль (md5)
  # to........Обязательно  Номер телефона получателя, в формате 71234567890
  # text......Обязательно  Текст сообщения, в UTF-8 кодировке
  # from......Обязательно  Подпись отправителя (например TEST)
  # date......Обязательно  Дата для отложенной отправки сообщения (количество секунд с 1 января 1970 года)
  def send to, text, from, date = nil
    params = {'to' => to, 'text' => text, 'from' => from}
    params = params.merge({'date' => date}) unless date.nil?
    params = @data.merge(params)
    response = self.send_query(@url + 'send/?' + params.to_param)
    if response['result'].present?
      if response['result'] == 'reject'
        @error_message = self.send_message(response)
        @error = true
        return false
      end
    end
    response
  end

  ### Проверка состояния отправленного сообщения
  def status sms_id
    params = @data.merge({'id' => sms_id})
    response = self.send_query(@url + 'status/?' + params.to_param)
    if response['result'].present?
      if response['result'] == 'reject'
        @error_message = self.status_message(response)
        @error = true
        return false
      end
    end
    response
  end

  ### + Проверка состояния счета
  def balance
    self.send_query(@url + 'balance/?' + @data.to_param)
  end

  ### +/- Список доступных подписей отправителя <-- не работает на стороне оператора в случае если нет подписей созданных пользователем
  def signatures
    self.send_query(@url + 'senders/?' + @data.to_param)
  end

  ### +/- Добавляем новую подпись <-- выявлены периодические несрабатывания на стороне оператора (проблема не решена, необходимы проверки)
  # подпись будет добавлена после ее подтверждения в смс-центре
  def add_signature signature
    params = @data.merge({'sign' => signature})
    self.send_query(@url + 'sign/?' + params.to_param)
  end

  def send_query path
    response = JSON.parse(open(path).read)

    if response.class == 'Hash' && response['result'].present?
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
    result = {
      'accepted' => 'Сообщение принято сервисом',
      'empty field' => 'Не все обязательные поля заполнены',
      'incorrect user or password' => 'Ошибка авторизации',
      'no credits' => 'Недостаточно sms на балансе',
      'incorrect sender name' => 'Неверная (незарегистрированная) подпись отправителя',
      'incorrect destination adress' => 'Неверно задан номер телефона (формат 71234567890)',
      'incorrect date' => 'Неправильный формат даты',
      'in blacklist' => 'Телефон находится в черном списке'
    }

    result[response['reason']]
  end

  def status_message response
    status = {
      'delivery success' => 'Сообщение доставлено',
      'delivery failure' => 'Ошибка доставки SMS (абонент в течение времени доставки находился вне зоны действия сети или номер абонента заблокирован)',
      'smsc submit' => 'Сообщение доставлено в SMSC',
      'smsc reject' => 'отвергнуто SMSC',
      'queue' => 'Ожидает отправки',
      'wait status' => 'Ожидание статуса (запросите позднее)',
      'incorrect id' => 'Неверный идентификатор сообщения',
      'empty field' => 'Не все обязательные поля заполнены',
      'incorrect user or password' => 'Ошибка авторизации'
    }

    status[response['reason']]
  end

  def auth_error response
    errors = {
      'empty field' => 'Не все обязательные поля заполнены',
      'incorrect user or password' => 'Ошибка авторизации',
      'no credits' => 'Недостаточно sms на балансе',
      'incorrect sender name' => 'Неверная (незарегистрированная) подпись отправителя',
      'incorrect destination adress' => 'Неверно задан номер телефона (формат 71234567890)',
      'incorrect date' => 'Неправильный формат даты',
      'in blacklist' => 'Телефон находится в черном списке'
    }

    errors[response['reason']]
  end

  def error
    {
      status: @error,
      message: @error_message
    }
  end
end
