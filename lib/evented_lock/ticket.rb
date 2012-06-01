require 'nest'

class Ticket

  #uniq_tag desc:
  #  The concurrent objects who point to same reference,
  #    or represent same row in database must use same uniq_tag.
  #
  #  NOTICE:
  #    We have to think the different databases use the same table name and have the same row id,
  #      so if we use the in multi database for control concurrence we have to specify database's uniq tag.
  #

  attr_accessor :tag

  #A ticket has a tag, but a tag can be included in many different tickets.
  def initialize(tag)
    self.tag = Nest.new("#{self.class.name}:#{tag}", redis)
    set_expire
  end

  def id
    self.object_id
  end

  #when pull action was timeout:
  #  1. expire ticket
  #  2. expire ticket's pull_list
  #
  def set_expire
    tag[id].setex timeout, id
    tag[:pull_list][id].expire timeout
  end

  #ticket dispatch:
  #  if none of the same tag is in executing
  #    push ticket's id to pull_list
  #  else
  #    push ticket's id to blocking_list
  #  end
  #
  def dispatch
    get_lock? ? push_to_client(id) : blocking
  end

  #将ticket插入阻塞队列
  def blocking
    tag[:blocking_list].lpush id
  end

  #弹出等待中的ticket
  def pop_blocking
    tag[:blocking_list].rpop
  end

  #将ticket加入到执行中set
  #利用set value 的唯一性保证执行中的ticket的uniq_tag是唯一的，从而避免并发
  def get_lock?
    tag.setnx :lock
=begin
    if tag.setnx(expire_at)
      true
    else
      if tag.get.to_i < current_time and tag.getset(expire_at).to_i < current_time
        true
      else
        false
      end
    end
=end
  end

  #移除执行中的ticket
  def release_lock
    tag.del
  end

  #将ticket推送到client，阻塞中的client得到ticket后开始执行block中的代码
  def push_to_client(ticket_id)
    tag[:pull_list][ticket_id].lpush ticket_id
  end

  def pull
    tag[:pull_list][id].brpop timeout
  end

  #每个ticket执行完成之后回调notify.
  #notify首先查看是否还有client在等待.
  #如果有:   从等待队列弹出ticket，然后推送给client
  #如果没有: 从执行中set移除该ticket的uniq_tag
  def notify
    ticket_id = next_ticket
    ticket_id ? push_to_client(ticket_id) : release_lock
  end

  #get the next usable ticket's id
  def next_ticket
    i = 0
    loop do
      ticket_id = pop_blocking

      if ticket_id && tag[ticket_id].exists
        return ticket_id
      end

      if tag[:blocking_list].llen == 0
        return false
      end

    end
  end

  def timeout
    EventedLock.timeout || 3
  end

  def redis
    EventedLock.redis
  end
end
