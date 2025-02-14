class UserMailer < ApplicationMailer
    def welcome_email (user)
        @user = user
        @url = "http://bitbridgeglobal.com"
        mail(to: @user.email, subject: "Welcome to Bit Bridge Globa")

    end


    def send_password_reset(user)
        @user = user
        @url =

    end

    def pawword_reset_url(user)
        "#{Rails.application.config.action_mailer.default_url_options[:host]}/reset_password?password_token=#{user.reset_password_token}&user_email=#{user.email}"

    end



end
