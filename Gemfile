source :rubygems


#group :development, :production, :test do
  gem 'sinatra', require: "sinatra/base"
  gem 'rack-oauth2-server', require: "rack/oauth2/sinatra"
  #gem 'rack'
  gem 'json'
  gem "memcache-client"
  gem "dm-sqlite-adapter", "~> 1.2.0.rc2"
  gem "dm-core" , "~> 1.2.0.rc2"
  gem "dm-migrations", "~> 1.2.0.rc2"
  gem "dm-is-reflective", "~> 1.0.0" # need dm-migration for *Adapter#type_map
  gem "bcrypt-ruby", require: "bcrypt"

#end

group :development, :test do
  gem "ruby-debug19", require: "ruby-debug"
  gem 'pry'
end

group :test do
  gem "rack-test", require: "rack/test"
  #gem "rspec"
  gem "simplecov", require: false
  gem "database_cleaner", git: 'git://github.com/bmabey/database_cleaner.git'
  gem "minitest", require: 'minitest/spec'
  #gem 'capybara'
end
