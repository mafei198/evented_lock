concurrent
==========

Redis based concurrence programming wrapper, which sequel concurrent actions by an unique tag and even share state in multi process .

client状态：
  1.waiting
  2.executing
  3.finish & notify

ticket状态:
  1.waiting
  2.executing

####流程######
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
