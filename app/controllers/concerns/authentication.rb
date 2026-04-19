module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

    def authenticated?
      Current.session.present?
    end

    def current_user
      Current.user
    end

    def require_authentication
      Current.session ||= find_session_by_cookie
      redirect_to signin_path unless Current.session
    end

    def find_session_by_cookie
      token = cookies.signed[:handshake_session_token]
      return if token.blank?

      Session.find_by(token_digest: Session.digest(token))
    end

    def start_new_session_for(user)
      session = user.sessions.create!
      cookies.signed.permanent[:handshake_session_token] = {
        value: session.plain_token,
        httponly: true,
        same_site: :lax
      }
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:handshake_session_token)
      Current.session = nil
    end
end
