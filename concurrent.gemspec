Gem::Specification.new do |s|
  s.name        = 'concurrent'
  s.version     = '0.0.1'
  s.date        = '2012-05-21'
  s.summary     = "concurrence oriented programming wrapper"
  s.description = "concurrent make concurrence oriented programming easy. With the wrapper you even don't need to think about concurrence, just live the code in the wraper"
  s.authors     = ["Savin Max"]
  s.email       = 'mafei.198@gmail.com'
  s.files       = ["lib/concurrent.rb",
                   'lib/concurrent/client.rb',
                   'lib/concurrent/ticket.rb',
                   'lib/concurrent/redis_key.rb']
  s.homepage    =
    'http://rubygems.org/gems/concurrent'
end
