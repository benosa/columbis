#-*- encoding : utf-8 -*-
ActionMailer::Base.smtp_settings = {
 :address              => 'smtp.gmail.com',
 :port                 => 587,
 :domain               => 'gmail.com',
 :user_name            => 'testdevmen@gmail.com',
 :password             => '20081989',
 :authentication       => 'plain',
 :enable_starttls_auto => true
}
