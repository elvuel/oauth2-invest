module RackOauth2
  module Custom
    class TapAccessToken < Struct.new :app, :options
      def call(env)
        request = Rack::Request.new(env)
        params = request.params
        if request.post? && request.path == "/oauth/access_token" && params["client_id"] && params["grant_type"] == "authorization_code"
          # only for third parties apps, check whether the client is the bundled apps
          bundled_app = Application.first(client_id: params[:client_id])
          if bundled_app.nil?
            response = app.call(env)
            status, header, body = *response
            body = JSON.parse(body.first)
            token_code = body["access_token"]
            # for only  the response body has access_token
            if token_code
              token = Rack::OAuth2::Server::AccessToken.from_token(token_code)
              oauth_identity, client_id = token.identity, token.client_id
              usr = User.get(oauth_identity)
              begin
                app_conn = usr.app_connections.first(client_id: client_id)
                unless app_conn
                  usr.app_connections.create(client_id: client_id, access_token: token_code)
                end
              rescue Exception => ex
                if logger = env["rack.logger"]
                  logger.error "TapAccessToken: Create user apps connection failed #{ex.message}"
                end
              end if usr # through the user exist bu need to check again
            end # if
            response
          end
        else
          app.call(env)
        end # if
      end #def call
    end # Serve
  end # Custom
end # RackOauth2