require 'redis'
#require File.join(ROOT, 'concurrent', 'ticket')

class DeadLock < StandardError; end

class Concurrent
  class << self
    attr_accessor :redis_path, :redis_port
  end

  def self.config
    yield self
  end

  #默认超时时间为8秒,超时后会抛出DeadLock异常
  def self.sync(uniq_tag, timeout = 8)
    ticket = Ticket.new(uniq_tag)

    ticket.dispatch

    if pull_ticket(uniq_tag, timeout)
      yield
    else
      raise DeadLock
    end
  ensure
    ticket.notify
  end

  def self.pull_ticket(uniq_tag, timeout)
    redis.brpop "client:#{uniq_tag}:list", timeout
  end

  #每次重启的时候清空redis保证锁队列的纯净性
  def self.redis(redis_host = '127.0.0.1', redis_port = 6379, num = 0)
    if @@redis
      @@redis
    else
      @@redis = Redis.new(:host => redis_host, :port => redis_port).select(num)
      @@redis.flushdb
      @@redis
    end
  end
end


=begin
uniq_tag = 'user:1'
1000.times do |i|
  Concurrent.sync(uniq_tag) do
    puts "sync: #{i + 1}"
    Profile.first.increment! :gems, 1
    puts '>>>>>executing....'
  end
end
=end
