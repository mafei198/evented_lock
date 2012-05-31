module RedisKey
  def blocking_list
    "blocking:#{@uniq_tag}:list"
  end

  def executing_set
    "executing:#{@uniq_tag}:list"
  end

  def client_list
    "client:#{self.object_id}:list"
  end
end
