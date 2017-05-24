class Student < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, 
         omniauth_providers: [:facebook]

  has_one :account, dependent: :delete

  # .edu email validation
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.edu/i

  # validates :email, 
  #   format: { with: VALID_EMAIL_REGEX }, 
  #   uniqueness: true,
  #   unless: lambda { email.nil? },
  #   if: 'provider.blank?'

  # To login with Facebook
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |student|
      student.provider = auth.provider
      student.uid = auth.uid
      student.email = auth.info.email
      student.password = Devise.friendly_token[0,20]
    end
  end

  def has_edu_email?
    # self.email =~ VALID_EMAIL_REGEX
  end

end
