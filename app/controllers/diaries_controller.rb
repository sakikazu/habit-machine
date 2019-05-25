class DiariesController < ApplicationController
  before_action :set_diary, only: [:show, :edit, :update, :destroy, :delete_image]
  before_action :set_form_variables, only: [:new, :edit]
  before_action :set_content_title, only: [:show, :edit]
  before_action :authenticate_user!

  SEARCH_KEY_TAGS = "tags:"
  SEARCH_KEY_HILIGHT = "hilight:"
  SEARCH_KEY_SINCE = "since:"
  SEARCH_KEY_UNTIL = "until:"
  SEARCH_KEY_YEAR = "year:"

  # GET /diaries
  # GET /diaries.json
  def index
    # TODO: Searchクラスに切り出したいところだがまあいいや
    @q = Diary.new
    @diaries = current_user.diaries

    # タグのリンクからの遷移の場合
    if params[:tag].present?
      tag = params[:tag]
      @diaries = @diaries.tagged_with(tag)
      @q.search_word = "tags:#{tag}"
    # 検索ボタンからの遷移の場合
    elsif params[:diary].present? and params[:diary][:search_word].present?
      search_word = params[:diary][:search_word]
      @q.search_word = search_word

      inputs = search_word.split(/[ 　]/).delete_if{|n| n.blank?}
      if inputs.present?
        tags = []
        hilight = false
        since_date = nil
        until_date = nil
        date_range = nil
        words = []
        inputs.each do |input|
          if input =~ /^#{SEARCH_KEY_TAGS}/
            input[SEARCH_KEY_TAGS.length..-1].split(",").each{|n| tags << n}
          elsif input =~ /^#{SEARCH_KEY_HILIGHT}/
            hilight = true
          elsif input =~ /^#{SEARCH_KEY_SINCE}/
            since_str = input[SEARCH_KEY_SINCE.length..-1]
            since_date = Date.parse(since_str) rescue nil
          elsif input =~ /^#{SEARCH_KEY_UNTIL}/
            until_str = input[SEARCH_KEY_UNTIL.length..-1]
            until_date = Date.parse(until_str) rescue nil
          elsif input =~ /^#{SEARCH_KEY_YEAR}/
            year = input[SEARCH_KEY_YEAR.length..-1]
            date_range = Date.new(year.to_i).beginning_of_year..Date.new(year.to_i).end_of_year rescue nil
          else
            words << input
          end
        end

        if tags.present?
          # タグのAND検索にしたいので、OR検索となるtagged_with(["aaa", "bbb"])という配列引数は使えない
          tags.each do |n|
            @diaries = @diaries.tagged_with(n)
          end
        end

        if hilight
          @diaries = @diaries.hilight
        end

        if since_date.present?
          @diaries = @diaries.where("record_at >= ?", since_date)
        end

        if until_date.present?
          @diaries = @diaries.where("record_at <= ?", until_date)
        end

        if date_range.present?
          @diaries = @diaries.where(record_at: date_range)
        end

        if words.present?
          words.each do |word|
            @diaries = @diaries.where('title like :q OR content like :q', :q => "%#{word}%")
          end
        end
      end
    end
    @diaries = @diaries.order(["record_at DESC", "id ASC"]).page(params[:page]).per(30)

    @tags = current_user.mytags.order("pinned DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @diaries }
    end
  end


  #
  # 「人生ハイライト」
  # デフォルト表示は、今年のもので、かつシークレットがfalseのもの
  #
  def hilight
    @action_name = '人生ハイライト'

    @years_including_diaries_count = current_user.diaries.hilight.group("DATE_FORMAT(record_at, '%Y')").count
                                       .sort_by {|k, _v| k}.reverse

    @diaries = current_user.diaries.hilight.order(["record_at ASC", "id ASC"])
    return if params[:all].present?

    record_at_range = if params[:year].present?
                        @year = params[:year].to_i
                        Date.new(@year).beginning_of_year..Date.new(@year).end_of_year
                      else
                        @year = Date.today.year
                        Date.today.beginning_of_year..Date.today.end_of_year
                      end
    @diaries = @diaries.where(record_at: record_at_range)

    # デフォルト時はシークレットがtrueのものは表示しない
    if params[:nosecret].blank?
      @diaries = @diaries.where(is_secret: false)
    end
  end

  #
  # 10年日記
  #
  def years
    @action_name = '10年日記'

    @year = params[:year].to_i
    diaries = current_user.diaries.where("DATE_FORMAT(record_at, '%Y') = ?", @year).select(:record_at, :title)

    @diaries_by_date = []
    (1..12).each do |month|
      @diaries_by_date[month] = []
      (1..31).each do |day|
        @diaries_by_date[month][day] = []
      end
    end

    diaries.each do |diary|
      month = diary.record_at.month
      day = diary.record_at.day
      @diaries_by_date[month][day] << diary
    end
  end

  def delete_image
    @diary.image = nil
    @diary.save
    redirect_to edit_diary_path(@diary), notice: "画像を削除しました."
  end

  # GET /diaries/1
  # GET /diaries/1.json
  def show
    if @diary.user != current_user
      redirect_to diaries_path, notice: "この日記は存在しません."
      return
    end

    if request.xhr?
      render partial: "show_ajax"
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @diary }
    end
  end

  # GET /diaries/new
  # GET /diaries/new.json
  def new
    record_at = if params[:record_at].present?
                  params[:record_at]
                elsif params[:days_ago].present?
                  Date.today - params[:days_ago].to_i
                else
                  Date.today
                end
    @diary = Diary.new(record_at: record_at)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @diary }
    end
  end

  # GET /diaries/1/edit
  def edit
    if @diary.user != current_user
      redirect_to diaries_path, notice: "この日記は存在しません."
      return
    end
  end

  # POST /diaries
  # POST /diaries.json
  def create
    @diary = Diary.new(diary_params)
    @diary.user_id = current_user.id

    respond_to do |format|
      if @diary.save
        format.html { redirect_to day_path(@diary.record_at.to_s), notice: "#{@diary.record_at.to_s(:short)}の日記を追加しました." }
        format.json { render json: @diary, status: :created, location: @diary }
      else
        set_form_variables
        format.html { render action: "new" }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diaries/1
  # PUT /diaries/1.json
  def update
    respond_to do |format|
      if @diary.update_attributes(diary_params)
        format.html { redirect_to day_path(@diary.record_at.to_s), notice: "#{@diary.record_at.to_s(:short)}の日記を更新しました." }
        format.json { head :no_content }
      else
        set_form_variables
        format.html { render action: "edit" }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diaries/1
  # DELETE /diaries/1.json
  def destroy
    day = @diary.record_at.to_s
    @diary.destroy

    respond_to do |format|
      format.html { redirect_to day_path(day), notice: '日記を削除しました.' }
      format.json { head :no_content }
    end
  end

  private
  def set_content_title
    @content_title = @diary.present? ? "#{@diary.record_at.strftime("%Y/%m/%d")}の日記「#{@diary.title}」" : ""
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_diary
    @diary = Diary.find(params[:id])
  end

  def set_form_variables
    @pinned_tags = CustomTag.pinned_tags(current_user)
    @latest_tags = CustomTag.latest_used_tags(current_user)
    @tagnames = current_user.mytags.order(:name).map{|t| t.name}.join(",")
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def diary_params
    params.require(:diary).permit(:content, :record_at, :title, :tag_list, :image, :is_hilight, :is_about_date, :is_secret, :search_word)
  end

end
