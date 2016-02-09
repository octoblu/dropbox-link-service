_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      port:           process.env.PORT || 80
      disableLogging: process.env.DISABLE_LOGGING == "true"

    @dropboxServiceUri = process.env.DROPBOX_SERVICE_URI || 'https://api.dropbox.com/'

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    # Use this to require env
    # @panic new Error('Missing required environment variable: ENV_NAME') if _.isEmpty @serverOptions.envName

    server = new Server @serverOptions, {meshbluConfig:  new MeshbluConfig().toJSON(),@dropboxServiceUri}
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
