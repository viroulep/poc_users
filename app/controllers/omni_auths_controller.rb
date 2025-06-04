class OmniAuthsController < ApplicationController
  allow_unauthenticated_access only: %i[ create failure ]

  def create
    puts "in create"
    auth = request.env["omniauth.auth"]
    puts auth
    uid = auth["uid"]
    provider = auth["provider"]
    redirect_path = request.env["omniauth.params"]&.dig("origin") || root_path

    identity = Identity.find_by(uid: uid, provider: provider)
    if authenticated?
      # User is signed in so they are trying to link an identity with their account
      if identity.nil?
        # No identity was found, create a new one for this user
        Identity.create(uid: uid, provider: provider, user: Current.user)
        redirect_to redirect_path, notice: "Account linked!"
      else
        # Identity was found, nothing to do
        # Check relation to current user
        if Current.user == identity.user
          redirect_to redirect_path, notice: "Already linked that account!"
        else
          # The identity is not associated with the current_user, illegal state
          redirect_to redirect_path, notice: "Account mismatch, try signing out first!"
        end
      end
    else
      # Check if identity was found i.e. user has visited the site before
      if identity.nil?
        # New identity visiting the site, we are linking to an existing User or creating a new one
        user = User.find_by(email_address: auth.info.email) || User.create_from_oauth(auth)
        identity = Identity.create(uid: uid, provider: provider, user: user)
      end
      start_new_session_for identity.user, source: provider
      redirect_to redirect_path, notice: "Signed in with #{provider}!"
    end
  end

  def failure
    redirect_to new_session_path, alert: "Authentication failed, please try again."
  end
end
