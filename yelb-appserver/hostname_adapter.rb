require_relative 'modules/hostname'

def hostname_adapter(event:, context:)
    hostnamedata = hostname()
    # use the return JSON command when you want the API Gateway to manage the http communication  
    # return hostnamedata
    { statusCode: 200, body: hostnamedata }
end

