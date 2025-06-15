class UserMailer < ApplicationMailer
    def welcome_email (user)
        @user = user
        attachments.inline['logo'] = File.read(Rails.root.join('app/assets/images/logo1.png'))

        @url = "https://bitbridgeglobal.com"
        @confirmation_url = confirm_url
        mail(to: @user.email, subject: "Welcome to Bit Bridge Global")

    end

      def login_alert(user)
        attachments.inline['logo'] = File.read(Rails.root.join('app/assets/images/logo1.png'))
        @user = user
        mail(to: @user.email, subject: "Login Alert to BitBridge Global")

    end

    def send_password_reset(user, token)
        @user = user
        @url = pawword_reset_url(user, token)
        mail(to: @user.email, subject: "Password Reset")

    end

    def pawword_reset_url(user, token)
        # "#{Rails.application.config.action_mailer.default_url_options[:host]}/reset_password?password_token=#{token}&email=#{user.email}"

        "https://bitbridgeglobal.com/reset_password?password_token=#{token}&email=#{user.email}"
        # "localhost:5173/reset_password?password_token=#{token}&email=#{user.email}"

    end

    def confirm_url
        "https://bitbridgeglobal.com/confirm_email"
    end



end
