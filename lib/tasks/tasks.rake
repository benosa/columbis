require 'gmail'
namespace :tasks do  
  desc "Parser mail"  
  task :parser_mail => :environment do
    
    mail = Gmail.new("testdevmen@gmail.com","20081989")
    mail.label("all")
    mail.inbox.emails.each do |email|
      usermailer = UserMailer.new
      usermailer.title = email.subject
      usermailer.body = email.html_part.body.decoded
      puts usermailer.message_id = email.message_id.match(/^(.+?)@/)[1]
      usermailer.task_id = email.subject.match(/\d+/)[0]
      usermailer.save
      email.label!("MayBeArchive")
      email.delete!
    end
  end
end