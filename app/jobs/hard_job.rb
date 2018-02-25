class HardJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    # Example from: http://bica.co/2015/03/08/using-active-job-with-sidekiq/
    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
  end
end
