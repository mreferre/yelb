#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####                    Yelb, a simple web application                       ####
################################################################################# 
  
#################################################################################
####   yelb-appserver.rb is the app (ruby based) component of the Yelb app   ####
####          Yelb connects to a backend database for persistency            ####
#################################################################################

require 'redis'
require 'socket'
require 'sinatra'

# the disabled protection is required when running in production behind an nginx reverse proxy
# without this option, the angular application will spit a `forbidden` error message
disable :protection

# the system variable RACK_ENV controls which environment you are enabling 
configure :production do
  set :redis, "redis-server"
  set :port, 4567
end
configure :test do
  set :redis, "redis-server"
  set :port, 4567
end
configure :development do
  set :redis, "localhost"
  set :port, 4567
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"

  # Needed for AngularJS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  halt HTTP_STATUS_OK
end

get '/api/pageviews' do

    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

	content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("pageviews")
    @pageviews = redis.get("pageviews")
end #get /api/pageviews

get '/api/hostname' do

    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

	content_type 'application/json'
    @hostname = Socket.gethostname
end #get /api/hostname

get '/api/getstats' do

    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

	content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("pageviews")
    @hostname = Socket.gethostname
    @pageviews = redis.get("pageviews")
    @stats = '{"hostname": "' + @hostname + '"' + ", " + '"pageviews":' + @pageviews + "}"
end #get /api/getstats


get '/api/getvotes' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

	content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    @outback = redis.get("outback")
    @ihop = redis.get("ihop")
    @bucadibeppo = redis.get("bucadibeppo")
    @chipotle = redis.get("chipotle")
    @ihop = "0" if @ihop.nil?
    @chipotle = "0" if @chipotle.nil?
    @outback = "0" if @outback.nil?
    @bucadibeppo = "0" if @bucadibeppo.nil?
    @votes = '[{"name": "outback", "value": ' + @outback + '},' + '{"name": "bucadibeppo", "value": ' + @bucadibeppo + '},' + '{"name": "ihop", "value": '  + @ihop + '}, ' + '{"name": "chipotle", "value": '  + @chipotle + '}]'
end #get /api/getvotes 

get '/api/ihop' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("ihop")
    @ihop = redis.get("ihop")
end #get /api/ihop 

get '/api/chipotle' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("chipotle")
    @ihop = redis.get("chipotle")
end #get /api/chipotle 

get '/api/outback' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("outback")
    @ihop = redis.get("outback")
end #get /api/outback 

get '/api/bucadibeppo' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redis, :port => 6379)
    redis.incr("bucadibeppo")
    @ihop = redis.get("bucadibeppo")
end #get /api/bucadibeppo 

