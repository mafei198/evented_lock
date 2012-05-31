root =  File.expand_path(File.dirname(__FILE__))
require File.join(root, 'redis_key')

class Ticket
  include RedisKey

  #uniq_tag desc:
  #  The concurrent objects who point to same reference,
  #    or represent same row in database must use same uniq_tag.
  #
  #  NOTICE:
  #    We have to think the different databases use the same table name and have the same row id,
  #      so if we use the in multi database for control concurrence we have to specify database's uniq tag.
  #

  #每个ticket拥有一个uniq_tag,concurrent-wrapper利用uniq_tag判定
  def initialize(uniq_tag)
    @uniq_tag = uniq_tag
    set_expire
  end

  def set_expire
    ticket_id = self.object_id
    redis.setex "#{@uniq_tag}:#{ticket_id}", timeout, @uniq_tag
  end

  def delete
    ticket_id = self.object_id
    redis.del "#{@uniq_tag}:#{ticket_id}"
  end

  def next_ticket
    i = 0
    loop do
      ticket_id = pop_blocking

      if ticket_id && redis.exists("#{@uniq_tag}:#{ticket_id}")
        return ticket_id
      end

      if redis.llen(blocking_list) == 0
        return false
      end

    end
  end

  #分发ticket
  #将ticket加入executing状态 成功: 将ticket推送给client
  #将ticket加入executing状态 失败: 代表有相同uniq_tag的ticket正在执行，将ticket推送到阻塞队列
  def dispatch
    executing ? push_to_client(self.object_id) : blocking
  end

  #将ticket插入阻塞队列
  def blocking
    #redis.lpush blocking_list, @uniq_tag
    redis.lpush blocking_list, self.object_id
  end

  #弹出等待中的ticket
  def pop_blocking
    redis.rpop blocking_list
  end

  #将ticket加入到执行中set
  #利用set value 的唯一性保证执行中的ticket的uniq_tag是唯一的，从而避免并发
  def executing
    redis.sadd executing_set, @uniq_tag
  end

  #移除执行中的ticket
  def rem_executing
    redis.srem executing_set, @uniq_tag
  end

  #将ticket推送到client，阻塞中的client得到ticket后开始执行block中的代码
  def push_to_client(ticket_id)
    redis.lpush "client:#{ticket_id}:list", ticket_id
  end

  def pull
    redis.brpop client_list, timeout
  end

  #每个ticket执行完成之后回调notify.
  #notify首先查看是否还有client在等待.
  #如果有:   从等待队列弹出ticket，然后推送给client
  #如果没有: 从执行中set移除该ticket的uniq_tag
  def notify
    ticket_id = next_ticket
    ticket_id ? push_to_client(ticket_id) : rem_executing
  end

  def timeout
    Concurrent.timeout || 3
  end

  def redis
    Concurrent.redis
  end
end
