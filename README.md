concurrent
==========

1.Redis based concurrence programming wrapper,
    which sequel concurrent actions by an unique tag and even share state in multi process.

###Client state
 - waiting
 - executing
 - finish & notify


###Ticket state
 - waiting
 - executing

work flow
----------
```
 client --> create ticket --> if has same ticket
                                push ticket in blocking queue
                          --> else
                                push ticket in executing queue
        --> blocking
        --> executing
        --> finish & notify
 blocking desc:
   1.use the redis blpop for waiting ticket
 notify actions:
   1.pop same ticket from the blocking queue and push in executing queue
   2.if there is no blocking ticket then delete the ticket from executing queue
```
Installation
-----------
  ```
  gem install evented_lock
  ```
Usage
-----
  ```
  require 'evented_lock'
  #configure redis
  EventedLock.config do |conf|
    conf.redis_host = '127.0.0.1'
    conf.redis_port = '6379'
  end

  #wrapper the concurrent code
  uniq_tag = 'test:1'
  EventedLock.sync(uniq_tag) do
    puts 1+1
  end
  ```
