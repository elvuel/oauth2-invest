# encoding: utf-8
module Helpers

  #def self.included(base);end

  def login_user
    @user = User.first
    post '/u/auth', {login: @user.send(@user.class.login_field), password: @user.name}
  end

  def logout!
    get '/u/logout'
  end

  def set_oauth_host
    app.settings.oauth.host = Rack::Test::DEFAULT_HOST
    @app_oauth = app.settings.oauth
  end

  def oauth2_clients_empty!
    clients = Rack::OAuth2::Server::Client.all
    clients.each { |client| Rack::OAuth2::Server::Client.delete(client.id) }
  end

  def register_oauth_client!(display_name = "HooyaTest")
    @client = Rack::OAuth2::Server.register(display_name: display_name, link: "http://localhost/",
                                            image_url: "http://www.google.com.hk/images/nav_logo86.png",
                                            scope: %{read write},
                                            redirect_uri: "http://localhost/oauth/callback")
  end

  def bundled_apps_empty!
    Application.destroy!
  end

  def create_apps_to_bundled!(count = 5)
    bundled_apps_empty!
    1.upto(count) do |num|
      register_oauth_client!("HooyaTest#{num}")
    end
    clients = Rack::OAuth2::Server::Client.all
    clients.each do |client|
      Application.create(name: client.display_name, client_id: client.id, created_at: Time.now)
    end
  end

  # Here take assertions in!
  def get_oauth_authorization!
    get "/oauth/authorize", {client_id: @client.id, redirect_uri: @client.redirect_uri, response_type: 'code'}
    last_response.status.must_equal 303 # see other
    last_response["Location"].index("http://#{@app_oauth.host}#{"/oauth/authorize"}").wont_be_nil
    @authorization_code = last_response["Location"].split("authorization=")[1]
  end

  def post_oauth_grant!
    post "/oauth/grant", {client_id: @client.id, authorization: @authorization_code}
    last_response["Location"].index(@client.redirect_uri).wont_be_nil
    last_response["Location"].index("code=").wont_be_nil
    req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
    @code = req.params["code"]
  end

end