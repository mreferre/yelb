require_relative 'getvotes'

def sendallgetbotes(sockets)
  votes = getvotes

  sockets.each { |ws| ws.send(votes) }
end
