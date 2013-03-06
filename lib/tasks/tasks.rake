require 'gmail'
namespace :tasks do  
  desc "Parser mail"  
  task :parser_mail => :environment do
    
    mail = Gmail.new("testdevmen@gmail.com","20081989")
    mail.inbox.emails.each do |email|
      usermailer = UserMailer.new
      usermailer.title = email.subject
      usermailer.body = email.html_part.body.decoded
      usermailer.message_id = email.message_id.match(/^(.+?)@/)[1]
      usermailer.task_id = email.subject.match(/\d+/)[0]
      puts usermailer.parent_id = email.header.to_s.match(/In-Reply-To:.<(.*)@/)[1]
      usermailer.save
      email.label!("MayBeArchive")
      email.delete!
    end

    mail.mailbox("[Gmail]/&BB4EQgQ,BEAEMAQyBDsENQQ9BD0ESwQ1-").emails.each do |email|
      usermailer = UserMailer.new
      usermailer.title = email.subject
      usermailer.body = email.body
      usermailer.message_id = email.message_id.match(/^(.+?)@/)[1]
      usermailer.task_id = email.subject.match(/\d+/)[0]
      #usermailer.parent_id = email.header.to_s.match(/In-Reply-To:.<(.*)@/)[0]
      usermailer.save
      email.label!("MayBeArchive")
      email.delete!
    end
  end
end