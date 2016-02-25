cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluConfig      = require 'meshblu-config'
debug              = require('debug')('dropbox-link-service:server')
Router             = require './router'
DropboxLinkService = require './services/dropbox-link-service'

class Server
  constructor: ({@disableLogging, @port}, {@meshbluConfig,@dropboxServiceUri})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    dropboxLinkService = new DropboxLinkService {@meshbluConfig,@dropboxServiceUri}

    router = new Router {dropboxLinkService,@meshbluConfig}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
