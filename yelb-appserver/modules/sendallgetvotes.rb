require_relative 'getvotes'

def sendallgetbotes(sockets)
  votes = getvotes

  warn(sockets)

  sockets.each { |ws| ws.send(votes) }
end
