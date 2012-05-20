#require File.expand_path './redis_key'
require File.join(ROOT, 'concurrent', 'redis_key')

class Ticket
  include RedisKey

  #uniq_tag desc:
  #  The concurrent objects who point to same reference,
  #    or represent same row in database must use same uniq_tag.
  #
  #  NOTICE:
  #    We have to thing the different databases use the same table name and have the same row id,
  #      so if we use the in multi database for control concurrence we have to specify database's uniq tag.
  #

  def initialize(uniq_tag)
    @uniq_tag = uniq_tag
  end

  def dispatch
    executing ? push_to_client : blocking
  end

  def blocking
    redis.lpush blocking_key, @uniq_tag
  end

  def pop_blocking
    redis.lpop blocking_key
  end

  def executing
    redis.sadd executing_key, @uniq_tag
  end

  def rem_executing
    redis.srem executing_key, @uniq_tag
  end

  def push_to_client
    redis.lpush client_key, @uniq_tag
  end

  def notify
    pop_blocking ? push_to_client : rem_executing
  end

  def redis
    Concurrent.redis
  end
end
