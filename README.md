concurrent
==========

1.Redis based concurrence programming wrapper,
    which sequel concurrent actions by an unique tag and even share state in multi process.

###Client state
 -waiting
 -executing
 -finish & notify


###Ticket state
 -waiting
 -executing

WORK FLOW DESC
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
   1.del the finished ticket from executing queue
   2.pop same ticket from the blocking queue and push in executing queue
```
Installation
-----------
  ```
  gem install concurrent
  ```
Usage
-----
  ```
  require 'concurrent'
  Concurrent.config do |conf|
    conf.redis_host = '127.0.0.1'
    conf.redis_port = '6379'
  end

  uniq_tag = 'test:1'
  Concurrent.sync(uniq_tag) do
    puts 1+1
  end
  ```
