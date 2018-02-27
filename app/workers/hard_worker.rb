class HardWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    logger.info "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
  end
end
