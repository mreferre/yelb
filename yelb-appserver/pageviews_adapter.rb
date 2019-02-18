require_relative 'modules/pageviews'

def pageviews_adapter(event:, context:)
    $redishost = ENV['redishost']
    $port = 6379
    pageviewscount = pageviews()
    # use the return JSON command when you want the API Gateway to manage the http communication  
    # return JSON.parse(pageviewscount)
    { statusCode: 200, body: pageviewscount }
end

