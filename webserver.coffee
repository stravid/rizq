fs = require 'fs'
express  = require 'express'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
postgres = require 'pg'


#configure passport
#
passport.use(new LocalStrategy(
  (username, password, done) ->
    User.findOne {username: username}, (err, user) ->
      if err 
        return done err
      if !user
        return done null, false, {message: 'Unknown user'}
      if !user.validPassword password
        return done null, false, {message: 'Invalid password'}
      return done null, user
))

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj


#create express app
#
app = express.createServer()

app.configure ->
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.session {secret: 'einszworisiko'}
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use express.static(__dirname + '/../../public')



app.post '/login', passport.authenticate 'local', 
  { successRedirect: '/', failureRedirect: '/login', failureFlash: true }

fs.readFile('./index.html', (err, html)->
  if err
    throw err
  app.get '/', (req, res)->
    res.writeHeader 200,{"Content-Type": "text/html"}
    res.write html
    res.end()
);

port = process.env.PORT || 5000

app.listen port, ->
  console.log port
