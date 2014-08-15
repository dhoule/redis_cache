Gem::Specification.new do |s|
  s.name          = 'redis_cache'
  s.version       = '0.0.0'
  s.date          = '2014-08-14'
  s.summary       = "Utilizes Redis as a cache to cut responce time by half."
  s.description   = "Utilizing Redis and Delayed Jobs, this gem queries the database after the number of seconds specified by REDIS_CACHE_REFRESH. " +
                    "The object will stay in $redis as long as the time specified by REDIS_CACHE_TIMEOUT. REDIS_CACHE_REFRESH needs to be much smaller " +
                    "than REDIS_CACHE_TIMEOUT."
  s.authors       = ["caine2003"]
  s.email         = 'dan@greplytix.com' 
  s.license       = 'MIT'
  s.requirements  = ['redis, ~> 3.1.0', 'redis-rails, ~> 4.0.0', 'delayed_job_active_record, ~> 4.0']
  s.files         = ["lib/redis_cache.rb"]
end      