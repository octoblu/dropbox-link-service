DropboxLinkController = require './controllers/dropbox-link-controller'
bearerToken           = require 'express-bearer-token'
meshbluAuth           = require 'express-meshblu-auth'
class Router
  constructor: ({@dropboxLinkService, @meshbluConfig}) ->
  route: (app) =>
    dropboxLinkController = new DropboxLinkController {@dropboxLinkService}
    app.use '/dropbox', bearerToken()
    app.use '/meshblu', meshbluAuth(@meshbluConfig)

    app.post '/dropbox/links', dropboxLinkController.generate
    app.get '/meshblu/links', dropboxLinkController.download
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
