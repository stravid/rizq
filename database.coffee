keys = require './keys.js'
postgres = require 'pg'

connectionString = keys.postgresConnection
client = new postgres.Client(connectionString)
client.connect()

module.exports = client
