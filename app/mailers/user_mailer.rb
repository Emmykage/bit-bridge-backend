class UserMailer < ApplicationMailer
    def welcome_email (user)
        @user = user
        @url = "http://bitbridgeglobal.com"
        mail(to: @user.email, subject: "Welcome to Bit Bridge Globa")

    end

end
