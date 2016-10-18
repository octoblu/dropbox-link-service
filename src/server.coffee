expressOctoblu     = require 'express-octoblu'
enableDestroy      = require 'server-destroy'
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
    app = expressOctoblu()

    dropboxLinkService = new DropboxLinkService {@meshbluConfig,@dropboxServiceUri}

    router = new Router {dropboxLinkService,@meshbluConfig}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
