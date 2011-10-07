source :rubygems


#group :development, :production, :test do
  gem 'sinatra', require: "sinatra/base"
  gem 'rack-oauth2-server', require: "rack/oauth2/sinatra"
  gem 'rack'
  gem "memcache-client"
#end

group :development, :test do
  gem "ruby-debug19", require: "ruby-debug"
end

group :test do
  gem "rack-test", require: "rack/test"
  #gem "rspec"
  gem "database_cleaner", git: 'git://github.com/bmabey/database_cleaner.git'
  gem "minitest", require: 'minitest/spec'
  #gem 'capybara'
  gem 'json'
end
