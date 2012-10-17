express  = require 'express'
keys = require './keys.js'
everyauth = require 'everyauth'
User = require './models/user.coffee'

#password authentication
#
everyauth
  .password
    .loginWith('login')
    .getLoginPath('/login')
    .postLoginPath('/login')
    .loginView('login.jade')
    .loginLocals( (req, res, done) ->
      setTimeout ->
        done null, { title: 'Async login' }
      , 200
    )
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
    .registerLocals( (req, res, done) ->
      setTimeout ->
        done null, {title: 'Async Register'}
      , 200
    )
    .validateRegistration( (newUserAttrs, errors) ->
      user = newUserAttrs.login;
      if (usersByLogin(user))
        errors.push('Login already taken');
      return errors;
    )
    .registerUser( (newUserAttrs) ->
      user = newUserAttrs[this.loginKey];
      return usersByLogin[user] = addUser(newUserAttrs);
    )
    .loginSuccessRedirect('/')
    .registerSuccessRedirect('/');


#twitter authentication
#
everyauth.twitter
  .consumerKey(keys.twitterKey)
  .consumerSecret(keys.twitterSecret)
  .findOrCreateUser((session, token, secret, login) ->
    promise = @.Promise().fulfill login
  ).redirectPath '/'

#facebook authentication
#
#TODO


#create express app
#
app = express.createServer()

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', __dirname + '/views'
  app.set 'view options', {title: "rizq"}
  app.use express.static __dirname + '/views'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session {secret: keys.appSecret}
  app.use everyauth.middleware()
  app.use app.router

#somekind of blackbox magic stuff to get custom authentication working
#https://github.com/bnoguchi/everyauth/issues/221
#
everyauth.helpExpress(app)


port = process.env.PORT || 4005
app.listen port, ->
  console.log port

#routes
#
app.get '/', (req, res)->
  res.render('index')

app.get '/login', (req, res)->
  res.render('login')
