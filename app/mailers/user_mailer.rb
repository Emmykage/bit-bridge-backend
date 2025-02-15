class UserMailer < ApplicationMailer
    def welcome_email (user)
        @user = user
        @url = "https://bitbridgeglobal.com"
        mail(to: @user.email, subject: "Welcome to Bit Bridge Globa")

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



end
