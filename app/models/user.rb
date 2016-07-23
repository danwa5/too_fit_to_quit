class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:fitbit_oauth2, :strava]

  has_many :identities, :dependent => :destroy

  def self.from_omniauth(auth, current_user)
    identity = Identity.where(provider: auth.provider, uid: auth.uid).first_or_create do |identity|
      if identity.user == nil
        if current_user.present?
          identity.user = current_user
        else
          user = User.new
          user.email = auth.info.email || "#{auth.uid}@#{auth.provider}.generated"
          user.password = Devise.friendly_token[0,20]
          identity.user = user
        end
      end
    end

    identity.access_token = auth['credentials']['token']
    identity.refresh_token = auth['credentials']['refresh_token']
    identity.expires_at = auth['credentials']['expires_at']
    identity.save
    identity.user
  end

  def fitbit_identity
    self.identities.where(provider: 'fitbit_oauth2').first
  end

  def strava_identity
    self.identities.where(provider: 'strava').first
  end
end
