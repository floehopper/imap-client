require "bundler/setup"

if RUBY_PLATFORM == "java"
  require "java"

  Dir["lib/greenmail-1.3.1b/lib/*.jar"].each { |f| require f }
  include_class "com.icegreen.greenmail.util.GreenMailUtil"
  include_class "com.icegreen.greenmail.util.GreenMail"
  include_class "com.icegreen.greenmail.util.ServerSetupTest"
  include_class "javax.mail.internet.MimeMessage"

  gm = GreenMail.new(ServerSetupTest::SMTP_IMAP)
  gm.start

  message = GreenMailUtil.newMimeMessage("test-body")
  message.setSubject("test-subject")
  user = gm.setUser("email@example.com", "password")
  user.deliver(message)

  email = "email@example.com"
  password = "password"
  host, port, ssl = "localhost", 3143, false
else
  email = ENV["EMAIL"]
  password = ENV["PASSWORD"]
  host, port, ssl = "imap.gmail.com", 993, true
end

require 'net/imap'
require 'mail'

Net::IMAP.debug = true
imap = Net::IMAP.new(host, port, ssl)
imap.login(email, password)
imap.select 'INBOX'
uids = imap.uid_search('ALL')
raw = uids.map {|uid| imap.uid_fetch(uid, '(BODY.PEEK[])')[0].attr['BODY[]']}
messages = raw.map {|m| Mail.new m}
messages.each do |m|
  puts m.subject
end

if RUBY_PLATFORM == "java"
  gm.stop
end
