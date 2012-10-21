database = require '../database.coffee'

class User
  @authenticate: (username, password, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 AND password = $2 LIMIT 1', [username, password], (error, result) ->
      callback null, result.rows[0] if result.rows.length > 0
      callback 'Login failed' unless result.rows.length > 0

  @register: (userAttrs, callback) ->
    database.query({
        text: 'INSERT into users(username, password) values' +
        '($1, $2)',
        values: [
                    userAttrs.login, 
                    userAttrs.password
                ]
        }, (error, result) ->
            callback null, true if result != undefined && !error
            callback 'Registration failed' if result == undefined || error
            )

  @validateUser: (user, callback) ->
    database.query 'SELECT * FROM users WHERE username = $1 LIMIT 1', [user], (error, result) ->
      callback 'Registration failed' if result.rows.length > 0
      callback null, true unless result.rows.length > 0

module.exports = User
