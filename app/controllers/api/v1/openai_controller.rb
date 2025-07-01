module Api
  module V1
    class OpenaiController < ApplicationController
      before_action :authenticate_user!

      # POST /api/v1/openai/chat
      def chat
        service = Openai::Chat.call(
          chat_params[:prompt],
          model: chat_params[:model] || 'gpt-4o-mini'
        )

        if service.success?
          render json: {
            success: true,
            response: service.response_text,
            model: service.model
          }, status: :ok
        else
          render json: {
            success: false,
            errors: service.errors
          }, status: service.status_error
        end
      end

      private

      def chat_params
        params.require(:openai).permit(:prompt, :model)
      end
    end
  end
end
