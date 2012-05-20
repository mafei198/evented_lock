ROOT = File.expand_path(File.dirname(__FILE__))

require File.join(ROOT, 'concurrent', 'client')
require File.join(ROOT, 'concurrent', 'ticket')
require File.join(ROOT, 'concurrent', 'redis_key')

Concurrent.config do |conf|
end

#run concurrent code in block
uniq_tag = 'test:1'
Concurrent.sync(uniq_tag) do
  puts 1+1
end
