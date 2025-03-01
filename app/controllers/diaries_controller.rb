class DiariesController < ApplicationController
  before_action :set_diary!, only: [:show, :edit, :update, :destroy, :delete_image, :create_image, :delete_sub_image, :update_categories, :histories]
  before_action :set_content_title, only: [:show, :edit]
  before_action :authenticate_user!

  # GET /diaries
  # GET /diaries.json
  def index
    searcher = Diary::Searcher.new(current_user.diaries, params)
    result_diaries = searcher.search
    @diaries = result_diaries.newer.page(params[:page]).per(20)
    @q = Diary.new
    @q.search_word = searcher.search_word
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

    @diaries = current_user.diaries.includes(:tags).hilight.older
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
      # TODO: is_secretは初期値を設定すべき
      @diaries = @diaries.where("is_secret = false OR is_secret IS NULL")
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

  #
  # 固定（ピン留め）
  #
  def pinned
    @all = params[:all].present?
    @tag = params[:tag]
    @diaries = current_user.diaries.pinned.order(id: :desc)
    if @tag.present?
      @diaries = @diaries.tagged_with(@tag)
    end
    tags = current_user.diaries.pinned.map { |d| d.tags }
    @tag_names = tags.flatten.map { |tag| tag.name }.uniq
  end

  # NOTE: /day/:date/diaries/:id もshowアクションで処理している。:dateはURLに付与されているのみで、処理に使っていない
  # GET /diaries/1
  # GET /diaries/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  # GET /diaries/new
  # GET /diaries/new.json
  def new
    set_form_variables
    record_at = if params[:record_at].present?
                  params[:record_at]
                elsif params[:days_ago].present?
                  Date.today - params[:days_ago].to_i
                else
                  Date.today
                end

    initial_main_in_day = !current_user.diaries.main_in(record_at).exists?
    @diary = Diary.new(record_at: record_at, main_in_day: initial_main_in_day)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render 'form_data' }
    end
  end

  # GET /diaries/1/edit
  def edit
    set_form_variables

    respond_to do |format|
      format.html
      format.json { render 'form_data' }
    end
  end

  # POST /diaries
  # POST /diaries.json
  def create
    @diary = Diary.new(diary_params)
    @diary.user_id = current_user.id

    respond_to do |format|
      if @diary.save
        format.html { redirect_to day_path(@diary.record_at.to_s, anchor: "diary-#{@diary.id}"), notice: "#{@diary.record_at.to_s(:short)}の日記を追加しました." }
        format.json { render partial: 'show', locals: { diary: @diary }, status: :created }
      else
        set_form_variables
        format.html { render action: "new" }
        # NOTE: jsonに直接文字列を指定する場合は、それにto_jsonをつけないとAxiosのerror.response.dataがnullになる。ハッシュだと不要なのになぜ・・
        format.json { render json: { message: @diary.errors.full_messages.join("\n") }, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diaries/1
  # PUT /diaries/1.json
  def update
    respond_to do |format|
      @diary.current_author = current_user
      if @diary.update(diary_params)
        # NOTE: rails5.1以降では、save後のカラム変更チェックはsaved_change_to_(column)?メソッドを使用すること
        @changed_record_at = @diary.saved_change_to_record_at? ? @diary.record_at : nil

        format.html { redirect_to day_path(@diary.record_at.to_s, anchor: "diary-#{@diary.id}"), notice: "#{@diary.record_at.to_s(:short)}の日記を更新しました." }
        format.json { render 'update', status: :created }
      else
        set_form_variables
        format.html { render action: "edit" }
        format.json { render json: { message: @diary.errors.full_messages.join("\n") }, status: :unprocessable_entity }
      end
    end
  end

  # TODO: 日記詳細ページで削除されると、head :okを返すだけなので真っ白の状態になる。ここでだけhtmlでリクエストすればいいが
  # DELETE /diaries/1
  # DELETE /diaries/1.json
  def destroy
    day = @diary.record_at.to_s
    @diary.destroy

    respond_to do |format|
      format.html { redirect_to day_path(day), notice: '日記を削除しました.' }
      format.json { head :ok }
    end
  end

  def append_memo
    @after_created_by_memo = false
    found_main_diaries = current_user.diaries.main_in(params[:diary][:record_at])
    if found_main_diaries.present?
      @diary = found_main_diaries.first
    else
      @diary = current_user.diaries.build(record_at: params[:diary][:record_at], main_in_day: true)
      @after_created_by_memo = true
    end
    @diary.append_memo(memo_text(params[:diary]))
    unless @diary.save
      render json: { message: @diary.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def delete_image
    @diary.eyecatch_image.purge
    render partial: 'show', locals: { diary: @diary }
  end

  # 日記サブ画像の登録
  def create_image
    @diary.images.attach(params[:image])
    uploaded_image = @diary.images.last
    uploaded_image_variant = uploaded_image.variant(Diary::SUB_IMAGE_VARIANT_HASH)
    render json: { imageId: uploaded_image.id, imageUrl: url_for(uploaded_image_variant), imageOrgUrl: url_for(uploaded_image) }
  end

  def delete_sub_image
    image = @diary.images.find(params[:image_id])
    image.purge

    head :no_content
  end

  def update_categories
    @diary.category_ids = params[:category_ids]
    @diary.save!
    render 'show'
  end

  def histories
    @history = @diary.histories.last
    raise ActiveRecord::RecordNotFound if @history.blank?
  end

  private

  def memo_text(memo_params)
    result = "- "
    result += "[#{memo_params[:time_memo]}]" if memo_params[:time_memo].present?
    result += "[#{memo_params[:label_memo]}] " if memo_params[:label_memo].present?
    result += memo_params[:memo]
    result
  end

  def set_content_title
    @content_title = @diary.present? ? "#{@diary.record_at.strftime("%Y/%m/%d")}の「#{@diary.title}」" : ""
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_diary!
    @diary = Diary.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @diary.can_manage?(current_user)
  end

  def set_form_variables
    @pinned_tags = current_user.mytags.only_pinned
    @latest_tags = current_user.mytags.without_pinned.last_used_order.limit(5)
    @tagnames = current_user.mytags.order(:name).map{|t| t.name}
  end

  def diary_params
    params.require(:diary).permit(:content, :record_at, :title, :tag_list, :eyecatch_image, :is_hilight, :is_about_date, :search_word, :main_in_day, :pinned, :pin_priority, :content_is_html)
  end
end
