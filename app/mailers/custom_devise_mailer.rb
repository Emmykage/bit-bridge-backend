# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  # Custom mailer for Devise to handle email confirmations
  default from: 'support@bitbridgeglobal.com'
  def confirmation_instructions(record, token, opts = {})
    # Customize the confirmation email
    base_url = Rails.application.credentials[:frontend_url] || ENV['FRONTEND_URL'] || 'https://bitbridgeglobal.com/'
    frontend_url = "#{base_url}confirmation?confirmation_token=#{token}"
    attachments.inline['logo'] = File.read(Rails.root.join('app/assets/images/logo1.png'))

    opts[:subject] = 'Confirm your account'
    @confirmation_link = frontend_url
    @token = token
    @user = record
    mail(to: record.email, subject: opts[:subject])
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @record = record
    opts[:subject] = 'Reset your password'
    super
  end
end
