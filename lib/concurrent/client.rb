require 'redis'
#require File.join(ROOT, 'concurrent', 'ticket')

class DeadLock < StandardError; end

class Concurrent
  class << self
    attr_accessor :redis_path, :redis_port, :timeout
  end

  def self.config
    yield self
  end

  #关闭redis所有持久化存储,避免clieng异常断开时产生脏数据
  def self.redis(redis_host = '127.0.0.1', redis_port = 6390, num = 0)
    @@redis ||= Redis.new(:host => redis_host, :port => redis_port, :db => num)
  end

  #默认超时时间为3秒,超时后会抛出DeadLock异常
  def self.sync(uniq_tag)
    ticket = Ticket.new(uniq_tag)

    ticket.dispatch

    ticket.pull ? yield : raise(DeadLock)
  ensure
    ticket.notify
  end

end
