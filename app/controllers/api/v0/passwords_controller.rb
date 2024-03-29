# frozen_string_literal: true
module Api
  module V0
    class PasswordsController < ApiController
      before_action :verify_access_token

      def update
        begin
          if (!password_params[:password].nil? && !password_params[:password].empty?) && (password_params[:password_confirmation].nil? || password_params[:password_confirmation].empty?)
            render status: 400, json: { "password_confirmation": [
              {
                "error": "ERR_BLANK",
                "description": "Attribute can't be blank"
              }
            ]
            }
          elsif (password_params[:password].nil? || password_params[:password].empty?) && (!password_params[:password_confirmation].nil? && !password_params[:password_confirmation].empty?)
            render status: 400, json: { "password": [
              {
                "error": "ERR_BLANK",
                "description": "Attribute can't be blank"
              }
            ]
            }
          elsif (password_params[:password].nil? || password_params[:password].empty?) && (password_params[:password_confirmation].nil? || password_params[:password_confirmation].empty?)
            render status: 400, json: { "password": [
              {
                "error": "ERR_BLANK",
                "description": "Attribute can't be blank"
              }
            ], "password_confirmation": [
              {
                "error": "ERR_BLANK",
                "description": "Attribute can't be blank"
              }
            ]
            }
          else
            verified!(@decoded_token["typ"])
            User.find(@decoded_token["sub"]).update!(password_params)
            render status: 200, json: { "message": "Password updated" }
          end

        rescue ActionController::ParameterMissing
          blank_error('user') # should not be thrown

        rescue ActiveRecord::RecordNotFound # Thrown when there is no User for id token["sub"]
          not_found_error('user')

        rescue ActiveRecord::RecordInvalid # Thrown when password != password_confirmation
          mismatch_error('password|password_confirmation')

        end
      end

      private

      def password_params
        params.require(:user).permit(:password, :password_confirmation)
      end
    end
  end
end
