textCrypt = require '../utils/text-crypt'
MeshbluHttp = require 'meshblu-http'

class DropboxLinkService
  constructor: ({@meshbluConfig}) ->
  generate: ({token,path}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    encryptedToken = textCrypt.encrypt token
    encryptedPath = textCrypt.encrypt path
    meshbluHttp.register dropbox: {encryptedToken,encryptedPath}, (error, device) =>
      return callback @_createError 500, error.message if error?
      link = "https://#{device.uuid}:#{device.token}@dropbox-link.octoblu.com/links"
      callback null, {link}

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = DropboxLinkService
