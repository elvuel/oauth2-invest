# encoding: utf-8
require "bundler/setup"

Bundler.require :default

require_relative 'config'

DataMapper.setup(:default, SQL_URL)

# TODO refactor with Dir.glob(..).each { |file| require file } if many
require_relative "models/user"
require_relative "models/application"

case ENV.fetch("RACK_ENV")
  when "test"
    Bundler.require :test
    Bundler.require :development
  when "development"
    Bundler.require :development
end

module RackOauth2
  module Custom
    class Serve < Struct.new :app, :options
      def call(env)
        request = Rack::Request.new(env)
        params = request.params
        if request.post?  and request.path == "/oauth/access_token" and params["client_id"] and params["grant_type"] == "password"
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

DataMapper.auto_upgrade!