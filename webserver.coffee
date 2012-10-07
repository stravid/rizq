express  = require 'express'
keys = require './keys.js'
everyauth = require 'everyauth'

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
  app.use express.static __dirname + '/views'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session {secret: 'einszworisiko'}
  app.use everyauth.middleware()
  app.use app.router

port = process.env.PORT || 4000
app.listen port, ->
  console.log port


app.get '/', (req, res)->
  console.log(req.session.auth);
  if(req.session.auth)
    user = req.session.auth.twitter.user.screen_name

  res.render('index', {
    layout: false
    locals: {user: user}
  })
