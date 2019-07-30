module Api
  module V1
    class DiariesController < ApiController
      before_action :authenticate_user_for_api
      before_action :set_diary, only: [:show, :update]

      def show
        render json: @diary
      end

      def update

      end

      private

      def set_diary
        @diary = Diary.find(params[:id])
      end
    end
  end
end
