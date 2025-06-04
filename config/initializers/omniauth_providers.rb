Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Rails.env.test?

  provider :google_oauth2, Rails.application.credentials.google.client_id!, Rails.application.credentials.google.client_secret!

  provider :github, Rails.application.credentials.github.client_id!, Rails.application.credentials.github.client_secret!, scope: "user:email"
end
