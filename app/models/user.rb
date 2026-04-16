class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "só pode conter letras, números e _" }

  def self.find_for_database_authentication(conditions)
    conditions[:username] = conditions[:username].downcase if conditions[:username]
    find_by(username: conditions[:username])
  end
end
