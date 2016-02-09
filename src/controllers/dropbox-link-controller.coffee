class DropboxLinkController
  constructor: ({@dropboxLinkService}) ->

  generate: (request, response) =>
    {token} = request
    {path} = request.body
    return response.sendStatus(422) unless path?
    return response.sendStatus(422) unless token?

    @dropboxLinkService.generate {token, path}, (error, body) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send body

  download: (request, response) =>
    {device} = request.meshbluAuth
    @dropboxLinkService.download {device}, (error, requestStream) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      requestStream.pipe response

module.exports = DropboxLinkController
