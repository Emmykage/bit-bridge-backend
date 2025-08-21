# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  # Custom mailer for Devise to handle email confirmations
  default from: 'support@bitbridgeglobal.com'
  def confirmation_instructions(record, token, opts = {})
    # Customize the confirmation email
    frontend_url = "https://bitbridgeglobal.com/confirmation?confirmation_token=#{token}"
    opts[:subject] = 'Confirm your account'
    @confirmation_link = frontend_url
    @token = token
    @record = record
    mail(to: record.email, subject: opts[:subject]) do |format|
      format.html do
        render html: <<~HTML.html_safe
          <h1>Welcome to BitBridge Global!</h1>
          <p>Please confirm your account by clicking the link below:</p>
          <p><a href='#{@confirmation_link}'>Confirm My Account</a></p>
        HTML
      end
    end
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @record = record
    opts[:subject] = 'Reset your password'
    super
  end
end
