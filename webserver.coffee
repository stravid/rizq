express  = require 'express'
keys = require './keys.js'
everyauth = require 'everyauth'
postgres = require 'pg'


#local db
conString = keys.postgresConnection
client = new postgres.Client(conString)

#Heroku db
#client = new pg.Client(process.env.DATABASE_URL);

client.connect()


usersByLogin = (email, password, callback)=>
  errors = []
  user = {}
  if(!email) 
    errors.push('Missing email')
  if(!password) 
    errors.push('Missing password')

  cli = client.query({
    text: "select * from users where email = $1",
    values: [email]
  })

  cli.on('row', (result)->
    user = result
  )

  cli.on('end', ()->
    console.log("currentPos")
    if(user == {})
      errors.push('Login failed')
    if(user.password != password) 
      errors.push('Login failed')
    if(errors.length) 
      callback(errors)
      return
    callback(user)
    client.end())



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
    .authenticate( (email, password) ->
      return usersByLogin(email, password, (result)->

        if(Object.prototype.toString.call(result) != '[object Array]')
          return result
        else
          console.log("WTF")
          return false
      )

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
      email = newUserAttrs.email;
      if (usersByLogin(email)) 
        errors.push('Login already taken');
      return errors;
    )
    .registerUser( (newUserAttrs) ->
      email = newUserAttrs[this.loginKey];
      return usersByLogin[email] = addUser(newUserAttrs);
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
