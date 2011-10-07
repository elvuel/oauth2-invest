# encoding: utf-8
require_relative 'spec_helper'

describe "auth steps" do

    before do
      app.settings.oauth.host = Rack::Test::DEFAULT_HOST
      @oauth = app.settings.oauth
      clients = Rack::OAuth2::Server::Client.all
      clients.each do |client|
        Rack::OAuth2::Server::Client.delete(client.id)
      end
      @redirect_uri = "http://localhost/oauth/callback"
      @client = Rack::OAuth2::Server.register(display_name: "HooyaTest", link: "http://localhost/",
                                              image_url: "http://www.google.com.hk/images/nav_logo86.png",
                                              scope: %{read write},
                                              redirect_uri: @redirect_uri)

      @client_id = @client.id
      @client_secret = @client.secret
    end

    describe "authorization code step validations" do
      it "should return a missing redirect_uri" do
        get @oauth.authorize_path
        last_response.body.must_equal "Missing redirect URL"
      end

      it "should mismatch the redirect uri" do
        get @oauth.authorize_path, {client_id: @client_id, redirect_uri: 'http://un-register-callback.com'}
        last_response.status.must_equal 302
        last_response["Location"].index("http://un-register-callback.com").wont_be_nil
        last_response["Location"].index("redirect_uri_mismatch").wont_be_nil
      end

      it "should return a invalid client id" do
        get @oauth.authorize_path, {client_id: "invalid_id", redirect_uri: @redirect_uri}
        last_response.status.must_equal 302
        last_response["Location"].index(@redirect_uri).wont_be_nil
        last_response["Location"].index("invalid_client").wont_be_nil
      end

      it "should return unsupported response type" do
        get @oauth.authorize_path, {client_id: @client_id, redirect_uri: @redirect_uri, response_type: 'c-de'}
        last_response.status.must_equal 302
        last_response["Location"].index(@redirect_uri).wont_be_nil
        last_response["Location"].index("unsupported_response_type").wont_be_nil
      end

      it "should response succeed and 303 redirect to same url with right authorization code" do
        get @oauth.authorize_path, {client_id: @client_id, redirect_uri: @redirect_uri, response_type: 'code'}
        last_response.status.must_equal 303 # see other
        last_response["Location"].index("http://#{@oauth.host}#{@oauth.authorize_path}").wont_be_nil
        authorization_code = last_response["Location"].split("authorization=")[1]

        get @oauth.authorize_path, {authorization: authorization_code.reverse}
        last_response.body.must_equal "Invalid authorization request"

        get @oauth.authorize_path, {authorization: authorization_code}
        last_response.status.must_equal 200
        last_response.body.index(@client.display_name).wont_be_nil
      end
    end

    describe "oauth #grant and #deny" do
      before do
        get @oauth.authorize_path, {client_id: @client_id, redirect_uri: @redirect_uri, response_type: 'code'}
        last_response.status.must_equal 303 # see other
        last_response["Location"].index("http://#{@oauth.host}#{@oauth.authorize_path}").wont_be_nil
        @authorization_code = last_response["Location"].split("authorization=")[1]
      end

      it "should redirect to call back with deny request" do
        post "/oauth/deny", { authorization: @authorization_code }
        last_response["Location"].index(@redirect_uri).wont_be_nil
        last_response["Location"].index("access_denied").wont_be_nil
      end

      it "should redirect to call back with accept request" do
        post "/oauth/grant", { client_id: @client_id, authorization: @authorization_code }
        last_response["Location"].index(@redirect_uri).wont_be_nil
        last_response["Location"].index("code=").wont_be_nil
        req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
        req.params["code"].wont_be_nil
      end

    end

    describe "oauth access token" do
      before do
        get @oauth.authorize_path, {client_id: @client_id, redirect_uri: @redirect_uri, response_type: 'code'}
        last_response.status.must_equal 303 # see other
        last_response["Location"].index("http://#{@oauth.host}#{@oauth.authorize_path}").wont_be_nil
        @authorization_code = last_response["Location"].split("authorization=")[1]
        post "/oauth/grant", { client_id: @client_id, authorization: @authorization_code }
        last_response["Location"].index(@redirect_uri).wont_be_nil
        last_response["Location"].index("code=").wont_be_nil
        req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
        @code = req.params["code"]
      end

      it "should post only" do
        get @oauth.access_token_path
        last_response.status.must_equal 405
      end

      it "should return bad request in grant_type authorization_code with wrong code" do
        post @oauth.access_token_path, { grant_type: "authorization_code", code: @code.reverse, redirect_uri: @redirect_uri, client_id: @client.id, client_secret: @client.secret }
        last_response.body.index("invalid_grant").wont_be_nil
      end

      it "should access token grant_type authorization_code with right code" do
        post @oauth.access_token_path, { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
      end

      # TODO
      #it "should access token with grant_type#password"
      #it "should access token with grant_type#none"
      #it "should request protect resources"


    end

end