database = require '../database.coffee'

class User
  @authenticate: (username, password, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 AND password = $2 LIMIT 1', [username, password], (error, result) ->
      callback null, result.rows[0] if result.rows.length > 0
      callback 'Login failed' unless result.rows.length > 0

  @register: (newUserAttributes, callback) ->
    database.query 'INSERT INTO users(username, password) VALUES ($1, $2)', [newUserAttributes.login, newUserAttributes.password], (error, result) ->
      callback null, true if result != undefined && !error
      callback 'Registration failed' if result == undefined || error

  @validateUsername: (user, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 LIMIT 1', [user], (error, result) ->
      callback 'Username already taken' if result.rows.length > 0
      callback null, true unless result.rows.length > 0

module.exports = User
