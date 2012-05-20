module RedisKey
  def blocking_key
    "blocking:#{@uniq_tag}:list"
  end

  def executing_key
    "executing:#{@uniq_tag}:list"
  end

  def client_key
    "client:#{@uniq_tag}:list"
  end
end
