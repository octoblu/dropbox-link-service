class DropboxLinkController
  constructor: ({@dropboxLinkService}) ->

  hello: (request, response) =>
    {hasError} = request.query
    @dropboxLinkService.doHello {hasError}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = DropboxLinkController
