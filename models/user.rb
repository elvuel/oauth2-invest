# encoding: utf-8

class User
  include DataMapper::Resource
  storage_names[:default] = 'users'
  is :reflective #is_reflective also
  reflect

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

  #@@users = %w(one two three)
  #
  #
  #attr_reader :name
  #
  #def self.find_by_name(user)
  #  return nil unless @@users.include?(user)
  #  new(user)
  #end
  #
  #def self.find(id)
  #  return nil if id.to_i <=0 or id.to_i > @@users.length
  #  new(@@users[id-1])
  #end
  #
  #def authenticate?(password)
  #  @name == password
  #end
  #
  #def initialize(user)
  #  @name = user
  #end
  #
  #def id
  #  @@users.index(@name).to_i + 1
  #end
  #
  #def password
  #  @name
  #end

end