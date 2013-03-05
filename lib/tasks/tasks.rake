require 'gmail'
namespace :tasks do  
  desc "Parser mail"  
  task :parser_mail => :environment do
    
    mail = Gmail.new("testdevmen@gmail.com","20081989")

    
    subject = mail.inbox.emails.each do |e|
      usermailer = UserMailer.new
      usermailer.title = e.subject
      puts usermailer.body = e.text_part.body.decoded
      usermailer.message_id = e.message_id
      usermailer.task_id = e.subject.match(/\d+/)[0]
      usermailer.save
    end

    #all_count = 0
    #parse_count = 0

  #   imap.search('all').each_slice(100) do |msg_ids|
  #     messages = imap.fetch(msg_ids, "BODY[TEXT]")

  #     all_count += messages.size
  #     messages.each do |mes|
  #       text = mes.attr["BODY[TEXT]"]
  #       if (/<(.*?\@.*?\..*?)>:\s.*said:(.*\s+.*\r?\n.*\r?\n)/) =~ text
  #         parse_count += 1
  #         mail = $1.strip
  #         error = $2.strip
  #         errors = error.gsub(/\r?\n/, ' ')

  #         client = ClientContactData.find_by_data(mail).person.client.name rescue ""

  #         f_error.write "#{client}\t#{mail}\t#{ errors }\n"
  #       else
  #         f_res.write " #{text}\n\n\n\n\n\n "
  #       end
  #     end
  #   end

  #   puts "Parse #{parse_count}/#{all_count}"

  #   f_error.close
  #   f_res.close

  #   imap.logout
  #   imap.disconnect

  end
end