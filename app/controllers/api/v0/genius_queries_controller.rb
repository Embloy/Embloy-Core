# frozen_string_literal: true
module Api
  module V0
    class GeniusQueriesController < ApiController
      before_action :verify_access_token, except: :query

      def create
        begin
          verified!(@decoded_token["typ"])
          res = GeniusQueryService::Encoder.call(@decoded_token["sub"], create_params)
          render status: 200, json: { "query_token" => res }
        end
      end

      def query
        begin
          token = params[:genius]
          res = GeniusQueryService::Decoder.call(token)
          render status: 200, json: { "query_result" => res }

        rescue ActiveRecord::RecordNotFound
          return not_found_error("genius_query")
        end
      end

      private

      def create_params
        params.permit(:job_id, :user_id, :expires_at)
      end

    end
  end
end