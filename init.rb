# encoding: utf-8
require "bundler/setup"

Bundler.require :default

require_relative 'config'

DataMapper.setup(:default, SQL_URL)

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each do |file|
  require file
end

require_relative "middlewares/bundled_application_serve"
require_relative "middlewares/tap_access_token"

case ENV.fetch("RACK_ENV")
  when "test"
    Bundler.require :test
    Bundler.require :development
  when "development"
    Bundler.require :development
end

DataMapper.auto_upgrade!

if ENV.fetch("RACK_ENV") == "development" && ENV["INIT_CLIENTS"]
  db_path = File.expand_path "db/development.db"
# empty user
  User.destroy!
  Application.destroy!
  AppConnection.destroy!
  %w(one two three).each do |item|
    user = User.new
    user.name, user.email, user.password = item, "#{item}@test.com", item
    user.encrypt_password
    user.save
  end

  Rack::OAuth2::Server.options.database = Mongo::Connection.new()[MONGO_DATABASE]

# empty client
  clients = Rack::OAuth2::Server::Client.all
  clients.each { |client| Rack::OAuth2::Server::Client.delete(client.id) }

  parent_folder = File.expand_path "../../", __FILE__
  entities = Dir[parent_folder + "/**"]
  entities.delete File.dirname(__FILE__)
  entities.reject! { |entity| !File.directory?(entity) }
  entities.collect!.with_index { |entity, index| [entity.gsub(parent_folder + "/", ''), 9290 + index + 3] }


# test clients
  entities.each do |config|
    app, port = config
    app_path = File.join(File.dirname(__FILE__), '..', app)
    if File.exist?(app_path) && File.directory?(app_path)

      client = Rack::OAuth2::Server.register(display_name: "HooyaClient-#{app}", link: "http://localhost:#{port}/",
                                             image_url: "http://www.google.com.hk/images/nav_logo86.png",
                                             scope: %{read write},
                                             redirect_uri: "http://localhost:#{port}/oauth/callback")
      # bundled app
      if app =~ /\Aapp_/
        Application.create(name: client.display_name, client_id: client.id, created_at: Time.now)
        File.open(app_path + "/config.rb", "w") do |f|
          f.write <<_CONFIG
# encoding: utf-8

SQL_URL =  "sqlite3://#{db_path}"
_CONFIG
        end
      end

      File.open(app_path + "/client_key.rb", "w") do |f|
        f.write <<-_EOF_
# encoding: utf-8

CLIENT_ID = "#{client.id}"
CLIENT_SECRET = "#{client.secret}"
MY_DISP_NAME = "#{client.display_name}"
APP_PORT = #{port}
        _EOF_
      end

      File.open(app_path + "/config.ru", "w") do |f|
        f.write <<_EOF
# encoding: utf-8
require File.join(File.dirname(__FILE__),  'app.rb')

#\\-p #{port}
run App
_EOF
      end
    end # if

  end # rest clients
end