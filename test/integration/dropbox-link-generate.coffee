http    = require 'http'
request = require 'request'
textCrypt = require '../../src/utils/text-crypt'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'

describe 'Generate', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    @dropbox = shmock 0xbabe

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @server = new Server serverOptions, {meshbluConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  afterEach (done) ->
    @dropbox.close done

  describe 'On POST /links', ->
    beforeEach (done) ->
      @registerDevice = @meshblu
        .post '/devices'
        .send
          dropbox:
            encryptedToken: textCrypt.encrypt 'oh-this-is-my-bearer-token'
            encryptedPath: textCrypt.encrypt 'path-to-file'
        .reply 201,
          uuid: 'one-time-device-uuid'
          token: 'one-time-device-token'

      options =
        uri: '/links'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          bearer: 'oh-this-is-my-bearer-token'
        json:
          path: 'path-to-file'

      request.post options, (error, @response, @body) =>
        done error

    it 'should register the device', ->
      @registerDevice.done()

    it 'should return a 201', ->
      expect(@response.statusCode).to.equal 201

    it 'should respond with the link', ->
      expect(@body.link).to.equal 'https://one-time-device-uuid:one-time-device-token@dropbox-link.octoblu.com/links'
