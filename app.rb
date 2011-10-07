# encoding: utf-8
require_relative "init"
require_relative "models/user"

class App < Sinatra::Base
  if development?
    reset!
    use Rack::Reloader, 0
    use Rack::Logger
  end

  set :sessions, true
  set :show_exceptions, false
  use Rack::Session::Memcache,
      key: 'rack.session.auth',
      memcache_server: "localhost:11211",
      expire_after: 3600

  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }

  register Rack::OAuth2::Sinatra

  oauth.authenticator = lambda do |usr, pwd|
    user = User.find_by_name(usr)
    user.name if user && user.authenticate?(pwd)
  end
  oauth.host = "localhost"
  oauth.database = Mongo::Connection.new[MONGO_DATABASE]

  #before "/oauth/*" do
  #  halt oauth.deny! if oauth.scope.include?("time-travel") # Only Superman can do that
  # rack-oauth2-server: current no grant_type 'refresh_code' TODO
  #end

  before do
    #oauth.authenticated?
  end
  helpers do
    def current_user
      User.find(session[:user_id]) if session[:user_id] || false
    end

  end

  get '/' do
    'hello'
  end

  post '/u/auth' do
    user = User.find_by_name(params[:username])
    if user && user.authenticate?(params[:password])
      session[:user_id] = user.id
      "login success!"
    else
      "login failed!"
    end
  end

  get '/u/name' do
    if current_user
      current_user.name
    else
      "nil"
    end
  end

  get "/oauth/authorize" do
    if params[:authorization]
      #auth_request = Rack::OAuth2::Server.get_auth_request(request.GET["authorization"])
      #client = Rack::OAuth2::Server.get_client(auth_request.client_id)
      # if client... end
      str = <<-HTML
      <h2>The application #{oauth.client.display_name}, #{oauth.client.link} </h2>
      HTML
      if current_user
        "TODO"# TODO
      else
        str << <<-CONFIRM
<form action="/oauth/grant" method="post">
        <button>Allow</button>
        <input type="hidden" name="authorization" value="#{oauth.authorization}">
        <input type="hidden" name="client_id" value="#{oauth.client.id}">
      </form>
        CONFIRM
      end
      str << <<-DENY
      <form action="/oauth/deny" method="post">
        <button>Deny</button>
        <input type="hidden" name="authorization" value="#{oauth.authorization}">
      </form>
      DENY
    end
  end

  # callback use HtmlForm and grant_type password
  # TODO 已登录用户 无需出现登录框， 可以直接请求或者点击‘ALLOW’ 内部APP无需 ALLOW就可直接使用！
  post '/oauth/access_token' do

  end

  # setting headers oauth.authorization and oauth.identity, then redirect back to consumer callback uri
  post "/oauth/grant" do
    oauth.grant! params[:client_id]
  end

  # set status 403 and redirect to consumer callback with access_denied
  post "/oauth/deny" do
    oauth.deny!
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