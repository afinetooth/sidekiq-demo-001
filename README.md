# README - WIP

## Demo rails app using Sidekiq as job runner for ActiveJob

### App description:

* Rails 5.1.4
* Ruby 2.5.0
* Sidekiq gem

### Dependencies:

To run this app in development, you will need:

* Redis installed on your local machine, running on port 6379
* If you're running redis on another port, replace 6379 with your port in app/config/initializers/sidekiq.rb

### How to run (development)

* Clone this repo with: `git clone git@github.com:afinetooth/sidekiq-demo-001.git`
* cd into the project directory: `cd sidekiq-demo-001`
* Make sure redis is running with: `redis-cli ping` should reply `PONG`; or, open a terminal window and start redis, typically something like: `redis redis-server /usr/local/etc/redis.conf` (depending on the location of your redis config)
* Open a second terminal window and start Sidekiq with: `bundle exec sidekiq`
* Open a third terminal window and run the example job in the rails runner:

`
rails runner "HardJob.perform_later(1,2,3)" && sleep 3 && tail -n 4 log/development.log
`

You should then see:

* A stdout message like this: `Running via Spring preloader in process 6716`
* A series of log message like:

Job enqueued - from Rails (ActiveJob):
`[ActiveJob] Enqueued HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) to Sidekiq(default) with arguments: 1, 2, 3`

Job starting - from Sidekiq:
`[ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] Performing HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) from Sidekiq(default) with arguments: 1, 2, 3`

Job in progress - custom log message from ActiveJob::HardJob:
`[ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] HardJob: I'm performing my job with arguments: [1, 2, 3]`

Job completed - from Sidekiq:
`[ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] Performed HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) from Sidekiq(default) in 0.06ms`