express  = require 'express'
keys = require './keys.js'
everyauth = require 'everyauth'
postgres = require 'pg'


usersByLogin = {
  'sepp': {
      login: 'sepp',
      email: 'sepp@rizq.com'
    , password: 'sepp'
  }
}

#password authentication
#
everyauth
  .password
    .loginWith('email')
    .getLoginPath('/login')
    .postLoginPath('/login')
    .loginView('login.jade')
    .loginLocals( (req, res, done) -> 
      setTimeout ->
        done null, { title: 'Async login' }
      , 200
    )
    .authenticate( (login, password) ->
      errors = []
      if(!login) 
        errors.push('Missing login')
      if(!password) 
        errors.push('Missing password')
      if(errors.length) 
        return errors
      user = usersByLogin[login]
      if(!user) 
        return ['Login failed']
      if(user.password != password) 
        return ['Login failed']
      return user
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
      login = newUserAttrs.login;
      if (usersByLogin[login]) 
        errors.push('Login already taken');
      return errors;
    )
    .registerUser( (newUserAttrs) ->
      login = newUserAttrs[this.loginKey()];
      return usersByLogin[login] = addUser(newUserAttrs);
    )
    .loginSuccessRedirect('/')
    .registerSuccessRedirect('/');


#twitter authentication
#
everyauth.twitter
  .consumerKey(keys.twitterKey)
  .consumerSecret(keys.twitterSecret)
  .findOrCreateUser((session, token, secret, user) ->
    promise = @.Promise().fulfill user
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
  app.use express.session {secret: 'einszworisiko'}
  app.use everyauth.middleware()
  app.use app.router

#somekind of blackbox magic stuff to get custom authentication working
#https://github.com/bnoguchi/everyauth/issues/221
#
everyauth.helpExpress(app)


port = process.env.PORT || 4000
app.listen port, ->
  console.log port

#routes
#
app.get '/', (req, res)->
  res.render('index')

app.get '/login', (req, res)->
  res.render('login')
