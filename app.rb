# encoding: utf-8
require_relative "init"

class App < Sinatra::Base
  if development?
    reset!
    use Rack::Reloader, 0
  end


  use Rack::Session::Memcache,
      key: "rack.session.application.#{ENV.fetch("RACK_ENV")}",
      memcache_server: "localhost:11211",
      expire_after: 3600

  set :sessions, true
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)

  if Sinatra::VERSION > "1.2.6"
    set :public_folder, Proc.new { File.join(root, "public") }
  else
    set :public, Proc.new { File.join(root, "public") }
  end


  use RackOauth2::Custom::Serve
  use RackOauth2::Custom::TapAccessToken
  register Rack::OAuth2::Sinatra

  oauth.authenticator = lambda do |login, password, client_id, scope|
    user = User.authenticate?(login: login, password: password)
    user.id if user
  end
  oauth.host = "localhost"
  oauth.database = Mongo::Connection.new[MONGO_DATABASE]

  helpers do
    def current_user
      if session[:user_id]
        User.get(session[:user_id])
      else
        false
      end
    end

    # this method currently let it be.
    def init_app_connections(user = current_user)
      # TODO moving its to the very position (n: refactor)
      if user && user.app_connections.empty?
        Application.all.each do |app|
          client = Rack::OAuth2::Server.get_client(app.client_id)
          # grant_type none call
          access_token = Rack::OAuth2::Server::AccessToken.get_token_for(user.id, client, client.scope)
          user.app_connections.create!(client_id: client.id, access_token: access_token.token)
        end
      end
    end

  end

  get '/' do
    'hello'
  end

  post '/oauth/access_token' do

  end

  # setting headers oauth.authorization and oauth.identity, then redirect back to consumer callback uri
  post "/oauth/grant" do
    if current_user
      oauth.grant! current_user.id
    else
      redirect request.env["HTTP_REFERER"]
    end
  end

  # set status 403 and redirect to consumer callback with access_denied
  post "/oauth/deny" do
    if current_user
      oauth.deny!
    else
      redirect request.env["HTTP_REFERER"]
    end
  end

  oauth_required "/u/name"#, "/user/authorized"

  # TODO for internal mini apps(n: refactor)
  get "/user/authorized" do
    user = User.get(oauth.identity)
    if user && oauth.access_token
      app_connection = user.app_connections.first(client_id: oauth.client.id)
      (app_connection.access_token == oauth.access_token).to_s
    else
      "false"
    end
  end

  # protected resource
  get '/u/name' do
    user = User.get(oauth.identity)
    if user
      user.name
    else
      "nil"
    end
  end

  post '/u/auth' do
    user = User.authenticate?(params)
    if user
      session[:user_id] = user.id
      init_app_connections
      "login success!"
    else
      "login failed!"
    end
  end

  get '/u/logout' do
    session[:user_id] = nil
    redirect '/'
  end

  get "/oauth/authorize" do
    if params[:authorization]
      if current_user
          <<-HTML
        <h2>The application #{oauth.client.display_name}, #{oauth.client.link} </h2>
          <form action="/oauth/grant" method="post">
          <button>Allow</button>
          <input type="hidden" name="authorization" value="#{oauth.authorization}">
          <input type="hidden" name="client_id" value="#{oauth.client.id}">
        </form>
        <form action="/oauth/deny" method="post">
          <button>Deny</button>
          <input type="hidden" name="authorization" value="#{oauth.authorization}">
        </form>
          HTML

      else
        redirect '/oauth/login?authorization=' + oauth.authorization
      end
    end
  end

  get "/oauth/login" do
    <<-HTML
    <h2>user login</h2>
<form action="/oauth/login_auth" method="post">
<input type="hidden" name="authorization" value="#{params[:authorization]}" />
<label>name:</label><input type="text" name="login" />
<label>password:</label><input type="password" name="password" />
<button>Connect</button>
</form>
    HTML
  end

  post "/oauth/login_auth" do
    user = User.authenticate?(params)
    if user
      session[:user_id] = user.id
      init_app_connections
      redirect "/oauth/authorize?authorization=#{params[:authorization]}"
    else
      "<a href='/oauth/login?authorization=#{params[:authorization]}'>back</a>"
    end
  end

  post '/client/register' do
    id = params.delete(:id) # do not allow
    display_name, link, image_url, scope, redirect_uri = params[:display_name], params[:link], params[:image_url], params[:scope], params[:redirect_uri]
    Rack::OAuth2::Server.register(
        display_name: display_name,
        link: link,
        image_url: image_url,
        scope: scope,
        redirect_uri: redirect_uri
    )
  end

  post '/client/update' do
    secret, display_name, link, image_url, scope, redirect_uri = params[:secret], params[:display_name], params[:link], params[:image_url], params[:scope], params[:redirect_uri]
    Rack::OAuth2::Server.register(
        id: params[:id],
        secret: secret,
        display_name: display_name,
        link: link,
        image_url: image_url,
        scope: scope,
        redirect_uri: redirect_uri
    )
  end

end

__END__
    #  response.status = 500
    #  content_type 'text/html'
    #  'Internal Server Error'