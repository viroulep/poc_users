class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create get_user_from_jwt ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

TMP_PUBKEY="-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA74acKL+tBwYuBRLBI3fh
UKJ+DitIFTHn6SkxgeXo3v2ea5VaEwdi9halt0DzFN7PyBB00BypHBW4ihXNR8Ms
3t6CIu+NHjg89oQv3HFAqDdeApPHooLyuKHZ3LJQykV9sgy6+qlEzdQMMY4nJNbh
D4IX2p04pgsNurbs/zxjYGI7j3VQa6wjqona16hUCDs40hB3m+7ihoGi7j/uCNfO
PHFoLvYxcf04YMveIC5H06KWrN09SbXPNgrenezz8nTBPp86y3fZNUFVuA9lzvUe
kbAozJWTGKAMurRGfS4xrn4ZJ+2RQW7ewm2FElbh0jn1zzC2AEIi5AdUtX8hOoP7
OQIDAQAB
-----END PUBLIC KEY-----"

  def new
  end

  # TODO: actually create a user/identity
  def get_user_from_jwt
    # Here we just check the signature for now
    bearer = request.authorization&.split("Bearer ")&.last
    head :unauthorized and return if bearer.blank?

    #public_key = OpenSSL::PKey::RSA.new(ENV["APP_JWT_PUBLIC_KEY"].gsub("\\n", "\n"))
    public_key = OpenSSL::PKey::RSA.new(TMP_PUBKEY)

    payload, = JWT.decode(
      bearer,
      public_key,
      true,
      { algorithms: ["RS256"],
        iss: "urn:example:issuer",
        verify_iss: true,
        aud: "urn:example:audience",
        verify_aud: true,
        verify_exp: true
      })
    #email = payload["email"]
    #provider = payload["provider"]
    #provider_subject = payload["provider_subject"]
    #head :unauthorized and return if email.blank?
    render json: payload
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user, source: :password
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
