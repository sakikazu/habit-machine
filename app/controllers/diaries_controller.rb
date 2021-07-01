class DiariesController < ApplicationController
  before_action :set_diary, only: [:show, :edit, :update, :destroy, :delete_image]
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
            @diaries = @diaries.find_by_word(word)
          end
        end
      end
    end
    @diaries = @diaries.newer.page(params[:page]).per(20)

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

    @diaries = current_user.diaries.hilight.older
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

  #
  # 毎日表示したいもの
  #
  def everyday
    @all = params[:all].present?
    @tag = params[:tag]
    @diaries = current_user.diaries.tagged_with('everyday').order(id: :desc)
    if @tag.present?
      @diaries = @diaries.tagged_with(@tag)
    end
    tags = current_user.diaries.tagged_with('everyday').map { |d| d.tags }
    names = tags.flatten.map { |tag| tag.name }
    @tag_names = names.uniq.delete_if { |name| name == 'everyday' }
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
    set_form_variables
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
      format.json { render 'form_data' }
    end
  end

  # GET /diaries/1/edit
  def edit
    set_form_variables
    if @diary.user != current_user
      redirect_to diaries_path, notice: "この日記は存在しません."
      return
    end

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
        format.json { render json: { message: @diary.errors.full_messages.join('\n') }, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diaries/1
  # PUT /diaries/1.json
  def update
    respond_to do |format|
      if @diary.update(diary_params)
        # NOTE: rails5.1以降では、save後のカラム変更チェックはsaved_change_to_(column)?メソッドを使用すること
        @changed_record_at = @diary.saved_change_to_record_at? ? @diary.record_at : nil

        format.html { redirect_to day_path(@diary.record_at.to_s, anchor: "diary-#{@diary.id}"), notice: "#{@diary.record_at.to_s(:short)}の日記を更新しました." }
        format.json { render 'update', status: :created }
      else
        set_form_variables
        format.html { render action: "edit" }
        format.json { render json: { message: @diary.errors.full_messages.join('\n') }, status: :unprocessable_entity }
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
      format.json { head :ok }
    end
  end

  def append_memo
    @after_created_by_memo = false
    found_diaries = current_user.diaries.where(record_at: params[:diary][:record_at]).tagged_with(Diary::TMP_BASE_TAG)
    if found_diaries.present?
      @diary = found_diaries.first
    else
      @diary = current_user.diaries.build(record_at: params[:diary][:record_at])
      @diary.tag_list << Diary::TMP_BASE_TAG
      @after_created_by_memo = true
    end
    @diary.append_memo(memo_text(params[:diary]))
    # TODO: 一応エラーハンドリングしたいところ
    @diary.save
  end

  def delete_image
    @diary.image = nil
    @diary.save
    render partial: 'show', locals: { diary: @diary }
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
  def set_diary
    @diary = Diary.find(params[:id])
  end

  def set_form_variables
    @pinned_tags = current_user.mytags.only_pinned
    @latest_tags = current_user.mytags.without_pinned.last_used_order.limit(5)
    @tagnames = current_user.mytags.order(:name).map{|t| t.name}
  end

  def diary_params
    params.require(:diary).permit(:content, :record_at, :title, :tag_list, :image, :is_hilight, :is_about_date, :is_secret, :search_word)
  end
end
