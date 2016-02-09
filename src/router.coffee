DropboxLinkController = require './controllers/dropbox-link-controller'

class Router
  constructor: ({@dropboxLinkService}) ->
  route: (app) =>
    dropboxLinkController = new DropboxLinkController {@dropboxLinkService}

    app.get '/hello', dropboxLinkController.hello
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
