require 'redis'
require File.join(ROOT, 'concurrent', 'ticket')

class Concurrent
  class << self
    attr_accessor :redis_path, :redis_port
  end

  def self.config
    yield self
  end

  def self.sync(uniq_tag)
    ticket = Ticket.new(uniq_tag)

    ticket.dispatch

    pull_ticket(uniq_tag)

    yield

    ticket.notify
  end

  def self.pull_ticket(uniq_tag)
    redis.brpop "client:#{uniq_tag}:list", 0
  end

  def self.redis(redis_host = '127.0.0.1', redis_port = 6379)
    @@redis ||= Redis.new :host => redis_host, :port => redis_port
  end
end


#require 'active_record'
#require 'mysql2'

#ActiveRecord::Base.establish_connection(
  #:adapter => 'mysql2',
  #:host    => 'localhost',
  #:suername => 'root',
  #:password => '',
  #:database => 'flames_develop',
  #:pool => 150
#)

#class Profile < ActiveRecord::Base
#end

#uniq_tag = 'user:1'
#1000.times do |i|
  #Concurrent.sync(uniq_tag) do
    #puts "sync: #{i + 1}"
    #Profile.first.increment! :gems, 1
    #puts '>>>>>executing....'
  #end
#end
