MeshbluHttp = require 'meshblu-http'
request     = require 'request'

class DropboxLinkService
  constructor: ({@meshbluConfig,@dropboxServiceUri}) ->

  generate: ({token,path}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    encryptedToken = privateKey.encrypt token, 'base64'
    encryptedPath = privateKey.encrypt path, 'base64'
    meshbluHttp.register dropbox: {encryptedToken,encryptedPath}, (error, device) =>
      return callback @_createError 500, error.message if error?
      link = "https://#{device.uuid}:#{device.token}@dropbox-link.octoblu.com/meshblu/links"
      callback null, {link}

  download: ({device}, callback) =>
    {encryptedToken,encryptedPath} = device.dropbox
    return callback @_createError 422, 'Invalid Device' unless encryptedPath?
    return callback @_createError 422, 'Invalid Device' unless encryptedToken?
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    path = privateKey.decrypt(encryptedPath).toString()
    token = privateKey.decrypt(encryptedToken).toString()

    options =
      baseUrl: @dropboxServiceUri
      uri: "/1/media/auto/#{path}"
      auth:
        bearer: token
      json: true

    request.post options, (error, response, body) =>
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body if response.statusCode > 299
      callback null, request.get body.url


  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = DropboxLinkService
