DropboxLinkController = require './controllers/dropbox-link-controller'

class Router
  constructor: ({@dropboxLinkService}) ->
  route: (app) =>
    dropboxLinkController = new DropboxLinkController {@dropboxLinkService}

    app.post '/links', dropboxLinkController.generate
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
