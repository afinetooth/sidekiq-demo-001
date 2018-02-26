# README for v0.1

This app demonstrates using Sidekiq as the job runner for ActiveJob

### App description:

* Rails 5.1.5
* Ruby 2.5.0
* Sidekiq gem

---

### Dependencies:

To run this app in development, you'll need:

* Redis, running on localhost at port 6379: 
	
	
	brew install redis

---

### Prepare to run in development:

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

### Run in development

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

### Deploy to production (Heroku)

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

	Or push local development branch (as master):

	`git push heroku local_branch_name:master`

5. Migrate database

	`heroku run rake db:migrate`

__Note:__
No need to start Sidekiq (or Redis) manually. The Redis Cloud instance we just created via heroku-cli is immediately available; and Heroku will start Sidekiq when it reads our Procfile.

---

### Run in production (Heroku)

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