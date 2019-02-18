require_relative 'modules/getvotes'

def getvotes_adapter(event:, context:)
    $yelbdbhost = ENV['yelbdbhost']
    $yelbdbport = 5432
    votes = getvotes()
    # use the return JSON command when you want the API Gateway to manage the http communication  
    # return JSON.parse(votes)
    { statusCode: 200, body: votes }
end

