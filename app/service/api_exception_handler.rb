# frozen_string_literal: true

module ApiExceptionHandler
  # frozen_string_literal: true

  extend ActiveSupport::Concern

  included do

    # =========== Job related exceptions ============
    # ===============================================

    rescue_from JWT::VerificationError,
                with: :token_verification_error

    #--------------------------------------

    rescue_from JWT::DecodeError,
                with: :token_decode_error

    #--------------------------------------

    rescue_from JWT::ExpiredSignature,
                with: :token_expired_error

    #--------------------------------------

    rescue_from JWT::InvalidIssuerError,
                with: :token_invalid_issuer_error

    #--------------------------------------

    rescue_from JWT::IncorrectAlgorithm,
                with: :token_algorithm_error

    #--------------------------------------

    rescue_from JWT::InvalidJtiError,
                with: :token_jti_error

    #--------------------------------------

    rescue_from JWT::InvalidIatError,
                with: :token_iat_error

    #--------------------------------------

    rescue_from JWT::InvalidSubError,
                with: :token_sub_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidJob::Unknown,
                with: :job_unknown_error

    # =========== User related exceptions ===========
    # ===============================================

    rescue_from CustomExceptions::InvalidUser::Unknown,
                with: :user_unknown_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidUser::Inactive,
                with: :user_inactive_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidUser::Unknown,
                with: :user_unknown_error

    #--------------------------------------

    rescue_from CustomExceptions::Unauthorized::NotOwner,
                with: :user_not_owner_error

    #--------------------------------------

    rescue_from CustomExceptions::Unauthorized::InsufficientRole::NotVerified,
                with: :user_role_to_low_error

    #--------------------------------------

    rescue_from CustomExceptions::Unauthorized::InsufficientRole,
                with: :user_role_to_low_error

    #--------------------------------------

    rescue_from CustomExceptions::Unauthorized::Blocked,
                with: :user_blocked_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidInput::BlankCredentials,
                with: :user_pw_blank

    # ========== Token related exceptions ===========
    # ===============================================

    rescue_from CustomExceptions::InvalidInput::Token,
                with: :token_invalid_input_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidInput::CustomEXP,
                with: :custom_validity_invalid_input_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidInput::SUB,
                with: :user_sub_error

    #--------------------------------------
    rescue_from CustomExceptions::InvalidInput::Quicklink::Client::Malformed,
                with: :client_token_malformed_error
    rescue_from CustomExceptions::InvalidInput::Quicklink::Client::Blank,
                with: :client_token_blank_error

    rescue_from CustomExceptions::InvalidInput::Quicklink::Request::Malformed,
                with: :request_token_malformed_error
    rescue_from CustomExceptions::InvalidInput::Quicklink::Request::Blank,
                with: :request_token_blank_error

    #--------------------------------------

    rescue_from CustomExceptions::InvalidInput::GeniusQuery::Malformed,
                with: :genius_query_malformed_error
    rescue_from CustomExceptions::InvalidInput::GeniusQuery::Blank,
                with: :genius_query_blank_error
  end

  private

  # =========== Job related exceptions ============
  # ===============================================

  def job_unknown_error
    not_found_error('job')
  end

  # =========== User related exceptions ===========
  # ===============================================

  def user_unknown_error
    not_found_error('user')
  end

  #--------------------------------------

  def user_inactive_error
    access_denied_error('user')
  end

  #--------------------------------------

  def user_not_owner_error
    access_denied_error('user')
  end

  #--------------------------------------

  def user_role_to_low_error
    access_denied_error('user')
  end

  #--------------------------------------

  def user_blocked_error
    access_denied_error('user')
  end

  #--------------------------------------

  def user_pw_blank
    blank_error('email|password')
  end

  # sub: subject of a token is not authorized to act (token specific 401s => exists for internal troubleshooting reasons)
  def user_sub_error
    unauthorized_error('user')
  end

  # ========== Token related exceptions ===========
  # ===============================================

  def token_invalid_input_error
    malformed_error('token')
  end

  def client_token_blank_error
    malformed_error('client_token')
  end

  def client_token_malformed_error
    malformed_error('client_token')
  end

  def request_token_blank_error
    malformed_error('request_token')
  end

  def request_token_malformed_error
    malformed_error('request_token')
  end

  def genius_query_malformed_error
    malformed_error('genius_query')
  end

  def genius_query_blank_error
    blank_error('genius_query')
  end

  def custom_validity_invalid_input_error
    malformed_error('validity')
  end

  #--------------------------------------

  def token_expired_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Attribute is expired', 401)
  end

  #--------------------------------------

  def token_invalid_issuer_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Attribute was signed by an unknown issuer', 401)
  end

  #--------------------------------------

  def token_algorithm_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Token was encoded with an unknown algorithm', 401)
  end

  #--------------------------------------

  def token_verification_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Attribute can\'t be verified', 401)
  end

  #--------------------------------------

  def token_jti_error
    access_denied_error('token')
    # render_error('token', 'ERR_INACTIVE', 'Attribute is blocked', 403)
  end

  #--------------------------------------

  def token_iat_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Attribute was timestamped incorrectly', 401)
  end

  #--------------------------------------

  def token_sub_error
    unauthorized_error('token')
    # render_error('token', 'ERR_INVALID', 'Attribute can't be allocated to an existing user', 401)
  end

  #--------------------------------------
  def token_decode_error
    unauthorized_error('token')
  end

  # ============ Basic render methods =============
  # ===============================================

  def blank_error(attribute)
    render_error(attribute, 'ERR_BLANK', 'Attribute can\'t be blank', 400)
  end

  #--------------------------------------

  def malformed_error(attribute)
    render_error(attribute, 'ERR_INVALID', 'Attribute is malformed or unknown', 400)
  end

  #--------------------------------------

  def unauthorized_error(attribute)
    render_error(attribute, 'ERR_INVALID', 'Attribute is invalid or expired', 401)
  end

  #--------------------------------------

  def access_denied_error(attribute)
    render_error(attribute, 'ERR_RAC', 'Proceeding is inhibited by an access restriction', 403)
  end

  #--------------------------------------

  def not_found_error(attribute)
    render_error(attribute, 'ERR_INVALID', 'Attribute can not be retrieved', 404)
  end

  #--------------------------------------

  def removed_error(attribute)
    render_error(attribute, 'ERR_REMOVED', 'Attribute was removed and cannot be accessed anymore', 409)
  end

  #--------------------------------------

  def unnecessary_error(attribute)
    render_error(attribute, 'ERR_UNNECESSARY', 'Attribute is already submitted', 422)
  end

  #--------------------------------------

  def mismatch_error(attribute)
    render_error(attribute, 'ERR_MISMATCH', 'Required matching attributes do not match', 422)
  end

  #--------------------------------------

  def biased_error(attribute)
    render_error(attribute, 'ERR_INVALID', 'Attribute is biased', 422)
  end

  #--------------------------------------

  def render_error(attribute, error, description, status)
    if attribute.class == Array
      bin = {}
      attribute.each do |att|
        bin["#{att}"] = [{ error: error, description: description }]
      end
      render status: status, json: bin
    else
      render status: status, json: { attribute => [{ error: error, description: description }] }
    end

  end

  #--------------------------------------
  def flatten_hash(hash)
    new_hash = {}

    hash.each do |key, value|
      if value.class == Hash && value.present?
        e = value
        new_hash[key] = {}

        e.each do |k, v|
          if k == key && v.class != Hash
            new_hash[key] = v
            break
          elsif v.class == Hash && v.present?
            bin = flatten_hash(v)
            new_hash[key] = bin
          else
            new_hash[key][k] = v
          end
        end
      else
        new_hash[key] = value
      end
    end

    if new_hash.size == 1 && new_hash.values[0].class == Hash
      new_hash = new_hash.values[0]
    end

    return new_hash

  end

  def flatted_first_element(hash)
    new = {}
    if hash.values.present? && hash.values[0].class == Hash
      e = hash.values[0]
      new[hash.keys[0]] = {}
      e.each do |k, v|
        if k == hash.keys[0] && v.class != Hash
          new = e.dup
          break
        elsif v.class == Hash && v.present?
          bin = ApiExceptionHandler.flatten_hash(v)
          new[hash.keys[0]] = bin
        else
          p new.inspect
          new[hash.keys[0]][k] = v
        end
      end
      hash = new
    end
    return hash
  end

  def ok
    # do nothing
    1
  end

end



