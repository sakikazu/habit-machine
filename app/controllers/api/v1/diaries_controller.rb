module Api
  module V1
    class DiariesController < ApiController
      before_action :authenticate_user_for_api
      before_action :set_diary, only: [:show, :append_memo]

      # 「やったこと」など特定のタグがついた日記を本日より指定日数前からの分を取得する
      def latest
        tag = params[:tag]
        latest_term = build_term(params[:limit])
        diaries = current_user.diaries.tagged_with(tag).where(record_at: latest_term).order("record_at DESC")

        # 期間の範囲分のDiaryを返したいので、DBに存在しない場合はインスタンス作って埋める
        result = []
        latest_term.each do |date|
          found_in_db = diaries.select { |d| d.record_at == date }
          if found_in_db.present?
            result += found_in_db
          else
            result << Diary.new(record_at: date)
          end
        end
        # todo: jsonBuilderで情報を絞りたいところ
        render json: result.reverse
      end

      def append_memo
        @diary.append_memo(params[:memo])
        @diary.save
        render json: @diary, status: :ok
      end

      def create
        p params
        diary = current_user.diaries.build(record_at: params[:record_at])
        diary.tag_list << params[:tag]
        diary.append_memo(params[:memo])
        diary.save
        render json: diary, status: :ok
      end

      # todo: 使わないかな
      def show
        render json: @diary
      end


      private

      def set_diary
        @diary = Diary.find(params[:id])
      end

      def build_term(limit)
        lim = limit.blank? ? 5 : limit.to_i
        start_date = Date.today - (lim - 1)
        start_date..Date.today
      end
    end
  end
end
