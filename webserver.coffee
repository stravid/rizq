express  = require 'express'


#create express app
#
app = express.createServer()

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', __dirname + '/views'
  app.use express.static __dirname + '/views'
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.session {secret: 'einszworisiko'}
  app.use app.router
  app.use express.static(__dirname + '/../../public')
  app.use express.errorHandler()


app.get '/', (req, res)->
  res.render('index.jade', {
    layout: false
  })

port = process.env.PORT || 4000

app.listen port, ->
  console.log port
