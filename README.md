# README for v0.2

This app demonstrates using Sidekiq as the job runner for ActiveJob

## App description:

* Rails 5.1.5
* Ruby 2.5.0
* Sidekiq gem

---

## Dependencies:

To run this app in development, you'll need:

* Redis, running on localhost at port 6379: 
	
	`brew install redis`

---

## Prepare to run in development:

1. Clone repo: 

	`git clone git@github.com:afinetooth/sidekiq-demo-001.git`

2. cd into project directory: 

	`cd sidekiq-demo-001`

3. Make sure redis is running: 

	`redis-cli ping` should reply `PONG`; 
	
	Or, open a terminal window and start redis: 
	
	`redis-server /usr/local/etc/redis.conf`

4. Open a second terminal window and start Sidekiq with: 

	`bundle exec sidekiq`

__Alternately, run the dependencies with Foreman__

1. Clone the repo: 

	`git clone git@github.com:afinetooth/sidekiq-demo-001.git`

2. cd into project directory: 

	`cd sidekiq-demo-001`

3. Run command: 

	`foreman start -f Procfile.dev`

To install foreman: 
	
	gem install foreman

---

## Run in development

In a free terminal window, run the example job using the rails runner:

	rails runner "HardJob.perform_later(1,2,3)" && sleep 3 && tail -n 4 log/development.log

Then you should see:

* __A stdout message like this:__ 

> Running via Spring preloader in process 6716

* __and a series of log messages like this:__

> [ActiveJob] Enqueued HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) to Sidekiq(default) with arguments: 1, 2, 3
>> ##### *^ Job enqueued by Rails ActiveJob*
	
> [ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] Performing HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) from Sidekiq(default) with arguments: 1, 2, 3	
>> ##### *^ Job started by Sidekiq*

> [ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] HardJob: I'm performing my job with arguments: [1, 2, 3]
>> ##### *^ Job in progress - Custom log message from ActiveJob::HardJob*

> [ActiveJob] [HardJob] [a87b3662-9c76-4b32-989d-e0a2a360d8b0] Performed HardJob (Job ID: a87b3662-9c76-4b32-989d-e0a2a360d8b0) from Sidekiq(default) in 0.06ms
>> ##### *^ Job completed by Sidekiq*

---

## Deploy to production (Heroku)

This app is ready to run at Heroku with these steps:

1. Create new Heroku app: 

	`heroku create demo-sidekiq-001`

2. Add a worker process: 

	`heroku addons:create rediscloud`

	Result should be something like:

> Creating rediscloud on ⬢ demo-sidekiq-001... free	
> Created rediscloud-lively-95217 as REDISCLOUD_URL	
> Use heroku addons:docs rediscloud to view documentation

3. Set REDIS_PROVIDER environment variable: 

	`heroku config:set REDIS_PROVIDER=REDISCLOUD_URL`

4. Push master branch:

	`git push heroku master`

	Or push local development branch (as master), for example:

	`git push heroku sidekiq:master`

5. Migrate database

	`heroku run rake db:migrate`

__Note:__
No need to start Sidekiq (or Redis) manually. The Redis Cloud instance we just created via heroku-cli is immediately available; and Heroku will start Sidekiq when it reads our Procfile.

---

## Run in production (Heroku)

From local project directory:

1. Open heroku rails console: 

	`heroku run rails console`

2. In heroku rails console, run job:

	`HardJob.perform_later(1,2,3)`

3. Exit heroku rails console: 

	`exit`

4. Tail heroku logs looking for HardJob:

	`heroku logs --tail | grep HardJob`

__You should see log messages like:__

> 2018-02-26T04:26:47.927148+00:00 app[worker.1]: 4 TID-p9k34 HardJob JID-ccbc6af995c0af9a832b23da INFO: start
>> ##### *^ External worker process started*

> 2018-02-26T04:26:47.931129+00:00 app[worker.1]: I, [2018-02-26T04:26:47.931027 #4] INFO -- : [ActiveJob] [HardJob] [3dce6355-5ba4-4611-bfc7-570584aea82e] Performing HardJob (Job ID: 3dce6355-5ba4-4611-bfc7-570584aea82e) from Sidekiq(default) with arguments: 7, 8, 9
>> ##### *^ Job started by Sidekiq*

> 2018-02-26T04:26:47.931438+00:00 app[worker.1]: D, [2018-02-26T04:26:47.931353 #4] DEBUG -- : [ActiveJob] [HardJob] [3dce6355-5ba4-4611-bfc7-570584aea82e] HardJob: I'm performing my job with arguments: [7, 8, 9]
>> ##### *^ Job in progress - Custom log message from ActiveJob::HardJob*

> 2018-02-26T04:26:47.932027+00:00 app[worker.1]: I, [2018-02-26T04:26:47.931521 #4] INFO -- : [ActiveJob] [HardJob] [3dce6355-5ba4-4611-bfc7-570584aea82e] Performed HardJob (Job ID: 3dce6355-5ba4-4611-bfc7-570584aea82e) from Sidekiq(default) in 0.3ms
>> ##### *^ Job completed by Sidekiq*

> 2018-02-26T04:26:47.932233+00:00 app[worker.1]: 4 TID-p9k34 HardJob JID-ccbc6af995c0af9a832b23da INFO: done: 0.005 sec
>> ##### *^ External worker process finished*

__You can also *monitor* Sidekiq via its built-in dashboard:__

[https://demo-sidekiq-001.herokuapp.com/sidekiq/](https://demo-sidekiq-001.herokuapp.com/sidekiq/)

---

---

## Good things to know now

### Basics

#### Sidekiq with ActiveJob

ActiveJob acts an an interface for external job runners, including Sidekiq. (Since Rails 4.2)

###### Advantages

* No need to change existing jobs
* Immediate performance increase over ActiveJob

###### Disadvantages

* Can't configure advanced Sidekiq features in ActiveJob

#### Sidekiq without ActiveJob

Running Sidekiq without ActiveJob just entails writing Workers instead of Jobs.

##### Jobs vs Workers

What's the difference between (ActiveJob) Jobs and (Sidekiq) Workers?

>"Short answer is they are the same thing. ActiveJob calls it a Job whereas Sidekiq calls it a Worker."

>-*[Mike Perham, author of Sidekiq, on StackOverflow](https://stackoverflow.com/questions/29925793/sidekiq-rails-4-2-use-active-job-or-worker-whats-the-difference)*

In other words, to get full Sidekiq functionality, just exchange your Jobs for Workers. Luckily, they're extremely similar, with only a few minor differences:

###### Jobs

* Live in *app/jobs*
* *Inherit* from ActiveJob
* Use class method *::perform_later(args)*: 
	
	`HardJob.perform_later(args)`
* Ex. *app/jobs/hard_job.rb*


	class HardJob < ActiveJob
	 
	 def perform(*args)
	  # Do something
	 end
	end
 
###### Workers

* Live in *app/workers*
* *Include* Sidekiq::Worker
* Use class method *::perform_async(args)*: 

	`HardWorker.perform_async(args)`
* Ex. *app/workers/hard_worker.rb*


	class HardWorker
 	 include Sidekiq::Worker
 	
 	 def perform(*args)
  	  # Do something
	 end
	end

##### Recommendation

Start with Jobs. Then switch to Workers when additional control is needed. Running both Jobs and Workers is OK. Both have full access to rails and so core behavior is written the same. Worst case may be confusion during debugging for the uninitiated, mostly due to logging differences. (See [Logging](#logging) below.)

#### Other interesting details

* Sidekiq has two parts:
  - Client: enqueues jobs
  - Server: pulls jobs from queue and executes them
* There are two (2) ways to run a job/worker:
  - `Job.perform_later(args)` or `Worker.perform_async(args)`; or
  - `Sidekiq::Client.push('class' => MyWorker, 'args' => [1,2,3])`
* Sidekiq boots Rails at the process level! 

> *[Each sidekiq server process has] the full Rails API including ActiveRecord, available for use.*

> -[*Sidekiq Wiki - The Basics*](https://github.com/mperham/sidekiq/wiki/The-Basics#server)

### Configuration

Basic configuration happens in *config/sidekiq.yml*:


	:concurrency: 5
	:verbose: true
	
	:queues:
  	 - [critical, 2]
  	 - default
  	 - low
  
	staging:
  	 :concurrency: 10
	production:
  	 :concurrency: 25
	   :verbose: false


#### Queues

Queues are processed in the order listed in *config/sidekiq.yml*. Queues can be *weighted* with a number, indicating here, for example, that the *critical* queue will be checked twice as frequently as the other queues (in addition to coming first):
	
	
	:queues:
  	 - [critical, 2]
  	 - default
  	 - low


#### Concurrency

* We can tune the concurrency of our sidekiq process.
	
	- Default is 25 threads per process in production. Best practice is *no higher than 50*
	- To work well with this concurrency, set production db connection pool to match:
	
	
		production:
		 adapter: postgresql
		 database: db_production
		 pool: 25

###### Advanced concurrency:

Sidekiq includes a [connection_pool_gem](https://github.com/mperham/connection_pool), which enables [connection pooling](https://github.com/mperham/sidekiq/wiki/Advanced-Options#connection-pooling) for in-memory data stores:

	
	MEMCACHED_POOL = ConnectionPool.new(:size => 10, :timeout => 3) { Dalli::Client.new }
	

#### Logging

* Sidekiq uses its own logger
* By default, Sidekiq logger logs to STDOUT, *for the process in which it's running*
* Write log messages in workers like: `logger.info "I'm doing stuff."`
* Workers can also call Rails.logger, like: `Rails.logger.info "I'm doing stuff and letting Rails log know."`
  - But those lines will appear in STDOUT for the *web process*, not for the separate *worker process* where sidekiq might be running, for instance, in production.

###### Advanced logging:

* To log to a *file* rather than STDOUT, specify a *log file*, either:
  - on the CLI: `bundle exec sidekiq -L log/sidekiq.log` or
  - in config/sidekiq.yml: `:logfile: ./log/sidekiq.log`
* Sidekiq defaults to using Ruby's standard library, Logger, so:
  - to turn off logging in test: `require 'sidekiq/testing'; Sidekiq::Logging.logger = nil`
  - to reduce verboseness in production: `Sidekiq::Logging.logger.level = Logger::WARN`
  - to customize log line format: `Sidekiq.logger.formatter = MyFormatter.new`
  - to use Log4r instead: `Sidekiq::Logging.logger = Log4r::Logger.new 'sidekiq'`

#### Mailers

* When Sidekiq is configured as ActiveJob's job runner, it handles ActionMailer's delayed deliveries
* Send a mailer using Sidekiq, like: `WelcomeMailer.deliver_later(@person)`

#### Error handling

Best practice is to let Sidekiq catch errors raised by your jobs. (See [Best practices - Error handling](##best-practices) below.)

Sidekiq automatically retries jobs that fail. Default behavior is:

* Job is re-tried for 21-days with [exponential back-off](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry)
* If jobs aren't fixed in 21-days and retries are exhausted, they go to the [Dead job queue](https://github.com/mperham/sidekiq/wiki/Error-Handling#dead-job-queue) in sidekiq monitor
* Jobs can be configured to *not_retry* `sidekiq_options :retry => false` or to *try a fewer number of times* `sidekiq_options :retry => 5`
* Among built-in hooks, `sidekiq_retries_exhausted do # stuff end` allows you to create a custom log message or [perform some other action before sidekiq dumps a job to the Dead queue](https://github.com/mperham/sidekiq/wiki/Error-Handling#configuration)


---

---

## Best practices

Some key best practices relate to:

### Passing arguments

Number one, most important:

* __Pass IDs rather than instances. Keep job parameters to simple JSON datatypes__. [Here's why](https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple).	


*A note on using GlobalIDs*

[ActiveJob supports using GlobalIDs for parameters](http://edgeguides.rubyonrails.org/active_job_basics.html#globalid). They're technically feasible, particularly when using ActiveJob. Still, [Mike doesn't like them](https://github.com/mperham/sidekiq/issues/2299). Here's why this might be confusing: GlobalIDs might seem feasible as a primitive datatype because they're displayed as strings, like `gid://app/Person/1`; however, they're actually objects. The recommendation here would be, if you use GlobalIDs, use them as strings, and have your Workers use `GlobalID::Locator.locate` on the flipside to find the objects. But then, why not just use IDs and ActiveRecord finders? [You still run the risk of the underlying database record changing between enqueued and execution](https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple). (One case, maybe: when your object instance comes from a class that's part of a polymorphic association, such that it could be one of two more entities. Basically, [one of the key reasons GlobalID was added to Rails](https://github.com/rails/globalid#global-id---reference-models-by-uri/).)

### Error handling

* [Use an error handling service](https://github.com/mperham/sidekiq/wiki/Error-Handling#best-practices) (Airbrake, Rollbar, etc.)

* [Let Sidekiq catch errors raised by your jobs](https://github.com/mperham/sidekiq/wiki/Error-Handling#best-practices).

> Let Sidekiq catch errors raised by your jobs. Sidekiq's built-in retry mechanism will catch those exceptions and retry the jobs regularly. The error service will notify you of the exception. You fix the bug, deploy the fix and Sidekiq will retry your job successfully.

> -[*Sidekiq Wiki - Error Handling Best Practices*](https://github.com/mperham/sidekiq/wiki/Error-Handling#best-practices)

* [Sidekiq responds to terminal signals](https://github.com/mperham/sidekiq/wiki/Signals). ([Use them like this](https://www.youtube.com/watch?v=0Q6CbF-ZmB8&feature=youtu.be)).


### Idempotency

* [Make jobs idempotent and transactional](https://github.com/mperham/sidekiq/wiki/Best-Practices#2-make-your-job-idempotent-and-transactional). Make sure your job can safely execute multiple times. Use database transactions when appropriate.

### Namespacing

* [Don't use namespaces with redis](http://www.mikeperham.com/2015/09/24/storing-data-with-redis/#namespaces).

### Race conditions

* [Avoid race conditions by using database transactions #with_lock](https://www.leighhalliday.com/avoid-race-conditions-with-postgres-locks). 

With concurrency comes race conditions. [Recursive locking](https://github.com/rails/rails/issues/10039#issuecomment-20033905) is a lot of fun.

> __Cannot find ModelName with ID=12345__

> Sidekiq is so fast that it is quite easy to get transactional race conditions where a job will try to access a database record that has not committed yet.

> -[*Sidekiq Wiki - Problems and Troubleshooting*](https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting#cannot-find-modelname-with-id12345)

---

---

## Next steps

### Run a Sidekiq Worker version of our ActiveJob Job

Whereas we ran our example job, HardJob, like this:

	heroku run rails console
	
	HardJob.perform_later(1,2,3)

We have a Sidekiq Worker, parallel to HardJob, called HardWorker, which you run like this:

	heroku run rails console
	
	HardWorker.perform_async(1,2,3)
	
You'll notice similar but slightly different log messages when you check the logs:

	heroku logs --tail | grep HardWorker

> 2018-02-26T23:02:13.526229+00:00 app[worker.1]: 4 TID-hxl3c HardWorker JID-40e0f4c5edbe78c243c91807 INFO: start

> 2018-02-26T23:02:13.527540+00:00 app[worker.1]: 4 TID-hxl3c HardWorker JID-40e0f4c5edbe78c243c91807 INFO: HardWorker: I'm performing my job with arguments: [9, 9, 9]

> 2018-02-26T23:02:13.527740+00:00 app[worker.1]: 4 TID-hxl3c HardWorker JID-40e0f4c5edbe78c243c91807 INFO: done: 0.002 sec

__The differences?__

1. With HardJob, Rails::ActiveJob generated the log messages; with HardWorker, all log messages come from Sidekiq.

2. Sidekiq's log line format is a little different:

	`#{time.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{context} #{severity}: #{message}\n`
	
	([*It can be changed*](https://github.com/mperham/sidekiq/wiki/Logging#customize-logger)*!*)

3. There are two (2) fewer messages.

	That's because Rails::ActiveJob reports two (2) additional log messages:
	* One when its job runner starts the job; 
	* The other when its job runner reports it finished.
	
We don't get these with HardWorker because there's no additional layer between us and Sidekiq.
	

### Tune performance

After we get a performance lift with Sidekiq, we may still want to tune performance with these steps:

1. [Tune timeouts for network connections like API calls](https://github.com/mperham/sidekiq/wiki/Using-Redis#life-in-the-cloud).

	`config.redis = { url: 'redis://...', network_timeout: 5 }`
	
2. [Don't use Redis as a cache; split off a separate instance configured as a persistent store](https://github.com/mperham/sidekiq/wiki/Using-Redis#memory).

3. [We may want to set up connection pooling using the connection_pool gem](https://github.com/mperham/sidekiq/wiki/Advanced-Options#connection-pooling).

### Upgrade to additional features

These seem likely as the next few upgrades:

1. Eliminate data loss with [Sidekiq Pro](https://sidekiq.org/products/pro.html) - $950/yr. 

> If a Sidekiq process crashes while processing a job, that job is lost. 

> Sidekiq Pro uses Redis's RPOPLPUSH command to ensure that jobs will not be lost if the process crashes or gets a KILL signal.

> The Sidekiq Pro client can withstand transient Redis outages or timeouts.

> -[*Sidekiq Pro site*](https://sidekiq.org/products/pro.html)

2. [Add an exception handling service, like Airbrake or Rollbar](https://github.com/mperham/sidekiq/wiki/Error-Handling#best-practices). (Sidekiq likes Honeybadger.)
	
3. Upgrade monitoring. Sidekiq's built-in dashboard is good but limited; we'll probably want to [upgrade to something like Inspeqtor](http://www.mikeperham.com/2014/10/02/introducing-inspeqtor/), also by Mike Perham.


### More reading

[This article](https://medium.com/@et3216/9-ways-to-boost-sidekiq-performance-correctly-in-practical-experiences-bfebe9ee0f28) was helpful as an overview of best practices.