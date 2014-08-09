class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,# :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
end
