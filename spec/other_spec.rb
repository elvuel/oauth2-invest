    #describe "oauth #grant and #deny" do
    #  before do
    #    get_oauth_authorization!
    #  end
    #
    #  it "should redirect to call back with deny request" do
    #    post "/oauth/deny", { authorization: @authorization_code }
    #    last_response["Location"].index(@client.redirect_uri).wont_be_nil
    #    last_response["Location"].index("access_denied").wont_be_nil
    #  end
    #
    #  it "should redirect to call back with accept request" do
    #    post "/oauth/grant", { client_id: @client.id, authorization: @authorization_code }
    #    last_response["Location"].index(@client.redirect_uri).wont_be_nil
    #    last_response["Location"].index("code=").wont_be_nil
    #    req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
    #    req.params["code"].wont_be_nil
    #  end
    #end
    #
    #describe "oauth access token" do
    #  before do
    #    get_oauth_authorization!
    #    post_oauth_grant!
    #  end
    #
    #  it "should post only" do
    #    get "/oauth/access_token"
    #    last_response.status.must_equal 405
    #  end
    #
    #  it "should raise status unauthorized when request a protected resource" do
    #    get '/u/name'
    #    last_response.status.must_equal 401
    #  end
    #
    #  it "should return bad request in grant_type authorization_code with wrong code" do
    #    post "/oauth/access_token", { grant_type: "authorization_code", code: @code.reverse, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    #    last_response.body.index("invalid_grant").wont_be_nil
    #  end
    #
    #  it "should access token grant_type authorization_code with right code" do
    #    post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    #    body = JSON.parse(last_response.body)
    #    body["access_token"].wont_be_nil
    #    logout!
    #    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    #    last_response.body.must_equal "nil"
    #    login_user
    #    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    #    last_response.body.must_equal @user.name
    #  end
    #
    #  it "should access token grant_type authorization_code with right code but wrong client_id" do
    #    post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id.to_s.reverse, client_secret: @client.secret }
    #    body = JSON.parse(last_response.body)
    #    body["error"].must_equal "invalid_client"
    #  end
    #
    #  # two-legged
    #  it "should access token with grant_type#none" do
    #    post "/oauth/access_token", { grant_type: "none", redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    #    body = JSON.parse(last_response.body)
    #    body["access_token"].wont_be_nil
    #    logout!
    #    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    #    last_response.body.must_equal "nil"
    #    login_user
    #    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    #    last_response.body.must_equal @user.name
    #  end
    #
    #end