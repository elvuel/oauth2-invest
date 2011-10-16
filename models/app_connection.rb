# encoding: utf-8

class AppConnection
  include DataMapper::Resource
  storage_names[:default] = 'app_connections'

  property :id, Serial
  property :user_id, String, required: true
  property :access_token, String, required: true
  property :client_id, String, required: true
  property :created_at, DateTime

end