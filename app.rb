# encoding: utf-8
require_relative "init"

class App < Sinatra::Base
  if development?
    reset!
    use Rack::Reloader, 0
    use Rack::Logger
  end

  use RackOauth2::Custom::Serve
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

  register Rack::OAuth2::Sinatra

  oauth.authenticator = lambda do |login, password, client_id, scope|
    user = User.authenticate?(login: login, password: password)
    user.id if user
  end
  oauth.host = "localhost"
  oauth.database = Mongo::Connection.new[MONGO_DATABASE]

  #before "/oauth/*" do
  #  halt oauth.deny! if oauth.scope.include?("time-travel") # Only Superman can do that
  #end

  #def set_current_user
  #  session[:user_id] = User.find(id: oauth.identity).id if oauth.authenticated?
  #end

  helpers do
    def current_user
      if session[:user_id]
        User.first(id: session[:user_id])
      else
        false
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

  oauth_required "/u/name"

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