Spree::TestMailer.class_eval do
  def test_named_email(email:)
    subject = "#{Spree::Store.current.name} #{Spree.t('test_mailer.test_email.subject')}"
    mail(to: email, from: from_address, subject: subject, template_name: 'test_email')
  end
end
