class User < ApplicationRecord
  has_many :cards, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "só pode conter letras, números e _" }

  validates :password, format: {
    with: /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W_]).*\z/,
    message: "deve conter pelo menos uma letra, um número e um caractere especial"
  }, if: :password_required?

  def self.find_for_database_authentication(conditions)
    conditions[:username] = conditions[:username].downcase if conditions[:username]
    find_by(username: conditions[:username])
  end

  has_many :cards, dependent: :destroy
end
