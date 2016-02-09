http        = require 'http'
request     = require 'request'
shmock      = require '@octoblu/shmock'
MeshbluHttp = require 'meshblu-http'
Server      = require '../../src/server'

describe 'Download', ->
  before ->
    @timeout 10000
    meshbluHttp = new MeshbluHttp({})
    {@privateKey, publicKey} = meshbluHttp.generateKeyPair()

    @privateKeyObj = meshbluHttp.setPrivateKey @privateKey

  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    @dropbox = shmock 0xbabe

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d
      privateKey: @privateKey

    @dropboxServiceUri = "http://localhost:#{0xbabe}"
    @server = new Server serverOptions, {meshbluConfig,@dropboxServiceUri}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  afterEach (done) ->
    @dropbox.close done

  describe 'On GET /meshblu/links', ->
    beforeEach (done) ->
      deviceAuth = new Buffer('one-time-device-uuid:one-time-device-token').toString 'base64'
      @getTheDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{deviceAuth}"
        .reply 200,
          uuid: 'one-time-device-uuid'
          dropbox:
            encryptedToken: @privateKeyObj.encrypt 'oh-this-is-my-bearer-token', 'base64'
            encryptedPath: @privateKeyObj.encrypt 'path-to-file', 'base64'

      @shareLink = @dropbox
        .post "/1/media/auto/path-to-file"
        .reply 201,
          url: "#{@dropboxServiceUri}/download-link"

      @downloadLink = @dropbox
        .get "/download-link"
        .reply 200, '{"some-data":true}'

      options =
        uri: '/meshblu/links'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'one-time-device-uuid'
          password: 'one-time-device-token'

      request.get options, (error, @response, @body) =>
        done error

    it 'should get the device', ->
      @getTheDevice.done()

    it 'should share the link', ->
      @shareLink.done()

    it 'should dowload the link', ->
      @downloadLink.done()

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should res', ->
      expect(@body).to.equal '{"some-data":true}'
