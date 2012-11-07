database = require './database.coffee'

class GameServer
  constructor: (userSockets) ->
    @userSockets = userSockets
