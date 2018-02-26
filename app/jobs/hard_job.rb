class HardJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something
    logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
  end
end
