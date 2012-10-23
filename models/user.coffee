database = require '../database.coffee'
bcrypt = require 'bcrypt'

class User
  @authenticate: (username, password, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 LIMIT 1', [username], (error, result) ->
      return callback 'Username not found' unless result.rows.length > 0

      if bcrypt.compareSync password, result.rows[0].encrypted_password
        callback null, result.rows[0]
      else
        callback 'Password not correct'

  @register: (newUserAttributes, callback) ->
    username = newUserAttributes.login
    encrypted_password = bcrypt.hashSync newUserAttributes.password, 10

    database.query 'INSERT INTO users(username, encrypted_password) VALUES ($1, $2)', [username, encrypted_password], (error, result) ->
      callback null, true if result != undefined && !error
      callback 'Registration failed' if result == undefined || error

  @validateUsername: (user, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 LIMIT 1', [user], (error, result) ->
      callback 'Username already taken' if result.rows.length > 0
      callback null, true unless result.rows.length > 0

module.exports = User
