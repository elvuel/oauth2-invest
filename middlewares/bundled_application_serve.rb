module RackOauth2
  module Custom
    class Serve < Struct.new :app, :options
      def call(env)
        request = Rack::Request.new(env)
        params = request.params
        if request.post?  && request.path == "/oauth/access_token" && params["client_id"] && params["grant_type"] == "password"
          bundled_app = Application.first(client_id: params["client_id"])
          if bundled_app
            app.call(env)
          else # return or set params[:client_id] to nil
            response = { error: 'unbundled_client', error_description: 'this client is not in bundle apps' }
            return [403, { "Content-Type"=>"application/json", "Cache-Control"=>"no-store" }, [response.to_json]]
          end
        else
          app.call(env)
        end
      end #call
    end # Serve
  end # Custom
end # RackOauth2