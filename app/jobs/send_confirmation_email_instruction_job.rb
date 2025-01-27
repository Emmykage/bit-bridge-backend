class SendConfirmationEmailInstructionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    UserMailer.welcome(self)

    # Do something later
  end
end
