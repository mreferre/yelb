require_relative 'modules/getstats'

def getstats_adapter(event:, context:)
    $redishost = ENV['redishost']
    $port = 6379
    stats = getstats()
    # use the return JSON command when you want the API Gateway to manage the http communication  
    # return JSON.parse(stats) 
    { statusCode: 200, body: stats }
end

