# encoding: utf-8
require_relative 'spec_helper'

describe "auth steps" do

    before do
      User.login_field = :email
      set_oauth_host
      oauth2_clients_empty!
      register_oauth_client!
    end

    describe "authorization code step validations" do
      it "should return a missing redirect_uri" do
        get "/oauth/authorize"
        last_response.body.must_equal "Missing redirect URL"
      end

      it "should mismatch the redirect uri" do
        get "/oauth/authorize", { client_id: @client.id, redirect_uri: 'http://un-register-callback.com' }
        last_response.status.must_equal 302
        last_response["Location"].index("http://un-register-callback.com").wont_be_nil
        last_response["Location"].index("redirect_uri_mismatch").wont_be_nil
      end

      it "should return a invalid client id" do
        get "/oauth/authorize", { client_id: "invalid_id", redirect_uri: @client.redirect_uri }
        last_response.status.must_equal 302
        last_response["Location"].index(@client.redirect_uri).wont_be_nil
        last_response["Location"].index("invalid_client").wont_be_nil
      end

      it "should return unsupported response type" do
        get "/oauth/authorize", { client_id: @client.id, redirect_uri: @client.redirect_uri, response_type: 'c-de' }
        last_response.status.must_equal 302
        last_response["Location"].index(@client.redirect_uri).wont_be_nil
        last_response["Location"].index("unsupported_response_type").wont_be_nil
      end

      it "should response succeed and 303 redirect to same url with right authorization code" do
        get_oauth_authorization!

        get "/oauth/authorize", { authorization: @authorization_code.reverse }
        last_response.body.must_equal "Invalid authorization request"

        logout! # user not logged in
        get "/oauth/authorize", { authorization: @authorization_code }
        last_response.status.must_equal 302
        last_response["Location"].index("login").wont_be_nil
        last_response["Location"].index(@authorization_code).wont_be_nil

        login_user
        get "/oauth/authorize", { authorization: @authorization_code }
        last_response.status.must_equal 200
        last_request.url.index("/oauth/authorize").wont_be_nil
        last_request.url.index(@authorization_code).wont_be_nil

        # add for simplecov
        get "/oauth/login", { authorization: @authorization_code }
        last_response.body.index(@authorization_code).wont_be_nil

        post "/oauth/login_auth", { login: @user.email, password: @user.name, authorization: @authorization_code }
        last_response.status.must_equal 302
        last_response["Location"].index("/oauth/authorize").wont_be_nil
        last_response["Location"].index(@authorization_code).wont_be_nil

        post "/oauth/login_auth", { login: @user.email.reverse, password: @user.name, authorization: @authorization_code }
        last_response.status.must_equal 200
      end
    end

    describe "oauth #grant and #deny" do
      before do
        get_oauth_authorization!
      end

      it "should redirect to call back with deny request" do
        post "/oauth/deny", { authorization: @authorization_code }
        last_response["Location"].index(@client.redirect_uri).wont_be_nil
        last_response["Location"].index("access_denied").wont_be_nil
      end

      it "should redirect to call back with accept request" do
        post "/oauth/grant", { client_id: @client.id, authorization: @authorization_code }
        last_response["Location"].index(@client.redirect_uri).wont_be_nil
        last_response["Location"].index("code=").wont_be_nil
        req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
        req.params["code"].wont_be_nil
      end
    end

    describe "oauth access token" do
      before do
        get_oauth_authorization!
        post_oauth_grant!
      end

      it "should post only" do
        get "/oauth/access_token"
        last_response.status.must_equal 405
      end

      it "should raise status unauthorized when request a protected resource" do
        get '/u/name'
        last_response.status.must_equal 401
      end

      it "should return bad request in grant_type authorization_code with wrong code" do
        post "/oauth/access_token", { grant_type: "authorization_code", code: @code.reverse, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
        last_response.body.index("invalid_grant").wont_be_nil
      end

      it "should access token grant_type authorization_code with right code" do
        post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
        body = JSON.parse(last_response.body)
        body["access_token"].wont_be_nil
        logout!
        get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
        last_response.body.must_equal "nil"
        login_user
        get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
        last_response.body.must_equal @user.name
      end

      it "should access token grant_type authorization_code with right code but wrong client_id" do
        post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id.to_s.reverse, client_secret: @client.secret }
        body = JSON.parse(last_response.body)
        body["error"].must_equal "invalid_client"
      end

      # two-legged
      it "should access token with grant_type#none" do
        post "/oauth/access_token", { grant_type: "none", redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
        body = JSON.parse(last_response.body)
        body["access_token"].wont_be_nil
        logout!
        get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
        last_response.body.must_equal "nil"
        login_user
        get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
        last_response.body.must_equal @user.name
      end

    end

end