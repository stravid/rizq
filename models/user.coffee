database = require '../database.coffee'

class User
  @authenticate: (email, password, callback) ->
    database.query 'SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1', [email, password], (error, result) ->
      callback null, result.rows[0] if result.rows.length > 0
      callback 'Login failed' unless result.rows.length > 0

module.exports = User
