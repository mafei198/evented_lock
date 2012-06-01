Gem::Specification.new do |s|
  s.name        = 'evented_lock'
  s.version     = '0.0.2'
  s.date        = '2012-06-01'
  s.summary     = "Proccess-shared Evented Pessimistic Lock , fast and reliable which can proccess thousands of locking actions per second."
  s.description = "Actions are waiting for lock in queue. There is no race condition for geting the lock, they just geting lock by evented"
  s.authors     = ["Savin Max"]
  s.email       = 'mafei.198@gmail.com'
  s.files       = ["lib/evented_lock.rb",
                   'lib/evented_lock/client.rb',
                   'lib/evented_lock/ticket.rb']

  s.homepage    = "https://github.com/mafei198/evented_lock"
  s.add_dependency "redis", "~> 2.2"
  s.add_dependency "nest", "~> 1.0"
end
