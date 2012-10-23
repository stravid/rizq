io = require 'socket.io'
express = require 'express'
keys = require './keys.js'
everyauth = require 'everyauth'
User = require './models/user.coffee'
MemoryStore = express.session.MemoryStore
parseCookie = require('connect').utils.parseCookie
Session = require('connect').middleware.session.Session

#authentication
everyauth
  .password
    .loginWith('login')
    .getLoginPath('/login')
    .postLoginPath('/login')
    .loginView('login.jade')
    .loginLocals({ title: 'Login' })
    .authenticate( (login, password) ->
      promise = @Promise()

      User.authenticate login, password, (error, login) ->
        promise.fulfill [error] if error?
        promise.fulfill login unless error?

      return promise
    )
    .getRegisterPath('/register')
    .postRegisterPath('/register')
    .registerView('register.jade')
    .registerLocals({ title: 'Register' })
    .validateRegistration( (newUserAttributes, errors) ->
      promise = @Promise()

      errors = []
      errors.push 'Password can not be blank' if newUserAttributes.password.length < 1
      errors.push 'Username can not be blank' if newUserAttributes.login.length < 1

      return promise.fulfill errors if errors.length > 0

      User.validateUsername newUserAttributes.login, (error, login)->
        promise.fulfill [error] if error?
        promise.fulfill login unless error?

      return promise
    )
    .registerUser( (newUserAttributes) ->
      promise = @Promise()

      User.register newUserAttributes, (error, login) ->
        promise.fulfill [error] if error?
        promise.fulfill login unless error?

      return promise
    )
    .loginSuccessRedirect('/')
    .registerSuccessRedirect('/')

#create express app
app = express.createServer()
sessionStore = new MemoryStore()

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', __dirname + '/views'
  app.set 'view options', { title: "rizq" }
  app.use express.static __dirname + '/views'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: keys.appSecret
    store: sessionStore
    key: 'express.sid'

  app.use everyauth.middleware()
  app.use app.router

#somekind of blackbox magic stuff to get custom authentication working
#https://github.com/bnoguchi/everyauth/issues/221
everyauth.helpExpress app

port = process.env.PORT || 4005

#socket io
socketIO = io.listen(app)

app.listen port, ->
  console.log "Rizq is running on port #{port}"





socketIO.set 'authorization', (data, accept) ->
  return accept 'No cookie transmitted', false unless data.headers.cookie?

  data.cookie = parseCookie data.headers.cookie
  data.sessionID = data.cookie['express.sid']
  data.sessionStore = sessionStore

  sessionStore.get data.sessionID, (error, session) ->
    if error? or !session?
      accept 'Error', false
    else
      data.session = new Session data, session
      accept null, true

socketIO.sockets.on 'connection', (socket) ->
  console.log "Socket with sessionID #{socket.handshake.sessionID} connected"

  localHandshake = socket.handshake

  intervalID = setInterval ->
    console.log "Session interval."
    localHandshake.session.reload ->
      localHandshake.session.touch().save()
  , 60 * 1000

  socket.on 'disconnect', -> clearInterval intervalID

#routes
app.get '/', (request, response) ->
  return response.redirect '/login' unless request.loggedIn

  response.render 'index'
