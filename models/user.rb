# encoding: utf-8

class User
  include DataMapper::Resource
  storage_names[:default] = 'users'
  is :reflective #is_reflective also
  reflect

  has n, :app_connections

  attr_accessor :password

  def self.login_field
    :email
  end

  def self.authenticate?(params={})
    return false unless user = first(login_field => params[:login])

    hash = BCrypt::Engine.hash_secret(
        params[:password], user.password_salt
    )

    if user.password_hash == hash
      user
    else
      false
    end
  end

  def encrypt_password
    if password && !password.empty?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash =
        BCrypt::Engine.hash_secret(password, password_salt)
    else
      true
    end
  end
end