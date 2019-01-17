require 'redis'

def pageviews()
        redis = Redis.new
        redis = Redis.new(:host => $redishost, :port => $port)
        redis.incr("pageviews")
        pageviewscount = redis.get("pageviews")
        redis.quit()
        return pageviewscount
end