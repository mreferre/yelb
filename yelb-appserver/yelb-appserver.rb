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
require 'pg'

# the disabled protection is required when running in production behind an nginx reverse proxy
# without this option, the angular application will spit a `forbidden` error message
disable :protection

# the system variable RACK_ENV controls which environment you are enabling
# if you choose 'custom' with RACK_ENV, all systems variables in the section need to be set before launching the yelb-appserver application
configure :production do
  set :redishost, "redis-server"
  set :port, 4567
  set :yelbdbhost => "yelb-db"
  set :yelbdbport => 5432
end
configure :test do
  set :redishost, "redis-server"
  set :port, 4567
  set :yelbdbhost => "yelb-db"
  set :yelbdbport => 5432
end
configure :development do
  set :redishost, "localhost"
  set :port, 4567
  set :yelbdbhost => "localhost"
  set :yelbdbport => 5432
end
configure :custom do
  set :redishost, ENV['REDIS_SERVER_ENDPOINT']
  set :port, 4567
  set :yelbdbhost => ENV['YELB_DB_SERVER_ENDPOINT']
  set :yelbdbport => 5432
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"

  # Needed for AngularJS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  halt HTTP_STATUS_OK
end

def restaurantsdbread(restaurant)
    con = PG.connect  :host => settings.yelbdbhost,
                      :port => settings.yelbdbport,
                      :dbname => 'yelbdatabase',
                      :user => 'postgres',
                      :password => 'postgres_password'
    con.prepare('statement1', 'SELECT count FROM restaurants WHERE name =  $1')
    res = con.exec_prepared('statement1', [ restaurant ])
    return res.getvalue(0,0)
end 

def restaurantsdbupdate(restaurant)
    con = PG.connect  :host => settings.yelbdbhost,
                      :port => settings.yelbdbport,
                      :dbname => 'yelbdatabase',
                      :user => 'postgres',
                      :password => 'postgres_password'
    con.prepare('statement1', 'UPDATE restaurants SET count = count +1 WHERE name = $1')
    res = con.exec_prepared('statement1', [ restaurant ])
end 

get '/api/pageviews' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

	content_type 'application/json'
    redis = Redis.new
    redis = Redis.new(:host => settings.redishost, :port => 6379)
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
    redis = Redis.new(:host => settings.redishost, :port => 6379)
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
    @outback = restaurantsdbread("outback")
    @ihop = restaurantsdbread("ihop")
    @bucadibeppo = restaurantsdbread("bucadibeppo")
    @chipotle = restaurantsdbread("chipotle")
    @votes = '[{"name": "outback", "value": ' + @outback + '},' + '{"name": "bucadibeppo", "value": ' + @bucadibeppo + '},' + '{"name": "ihop", "value": '  + @ihop + '}, ' + '{"name": "chipotle", "value": '  + @chipotle + '}]'
end #get /api/getvotes 

get '/api/ihop' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    restaurantsdbupdate("ihop")
    @ihop = restaurantsdbread("ihop")
end #get /api/ihop 

get '/api/chipotle' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    restaurantsdbupdate("chipotle")
    @chipotle = restaurantsdbread("chipotle")
end #get /api/chipotle 

get '/api/outback' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    restaurantsdbupdate("outback")
    @outback = restaurantsdbread("outback")
end #get /api/outback 

get '/api/bucadibeppo' do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
 
    restaurantsdbupdate("bucadibeppo")
    @bucadibeppo = restaurantsdbread("bucadibeppo")
end #get /api/bucadibeppo 
