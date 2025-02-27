class Diary::Searcher
  SEARCH_KEY_TAGS = "tags:"
  SEARCH_KEY_HILIGHT = "hilight:"
  SEARCH_KEY_SINCE = "since:"
  SEARCH_KEY_UNTIL = "until:"
  SEARCH_KEY_YEAR = "year:"
  SEARCH_KEY_IMAGE = "image:"

  attr_reader :search_word

  def initialize(diaries, params = {})
    @diaries = diaries
    @params = params
  end

  def search
    @diaries = @diaries.includes(:tags)

    # タグのリンクからの遷移の場合
    if tag_param.present?
      @diaries = search_by_only_tag(tag_param)
      @search_word = "tags:#{tag_param}"
    # 検索ボタンからの遷移の場合
    elsif search_word_param.present?
      @diaries = search_by_word(search_word_param)
      @search_word = search_word_param
    end

    @diaries
  end

  private

  def search_by_only_tag(tag)
    @diaries.tagged_with(tag)
  end

  def search_by_word(search_word_param)
    inputs = search_word_param.split(/[ 　]/).reject(&:blank?)
    return if inputs.blank?

    tags = []
    hilight = false
    has_image = false
    since_date = nil
    until_date = nil
    date_range = nil
    words = []
    inputs.each do |input|
      if input =~ /^#{SEARCH_KEY_TAGS}/
        input[SEARCH_KEY_TAGS.length..-1].split(",").each{|n| tags << n}
      elsif input =~ /^#{SEARCH_KEY_HILIGHT}/
        hilight = true
      elsif input =~ /^#{SEARCH_KEY_IMAGE}/
        has_image = true
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


    if has_image
      # NOTE: Diaryのeyecatch_imageとimagesのいずれかの画像がひもづいていることを検索するため left_joinsを2つ指定するが、実質は同じテーブルを見ている。
      #       このケースでは、railsが2つ目に自動的にaliasを設定するみたいで、whereではそれを指定している `images_attachments_diaries`
      #       ActiveStorageが自動でxxx_attachmentという関連を追加していることや、aliasを設定することもドキュメントからは多分わからない仕様
      @diaries = @diaries
        .left_joins(:eyecatch_image_attachment)
        .left_joins(:images_attachments)
        .where('active_storage_attachments.id IS NOT NULL OR images_attachments_diaries.id IS NOT NULL')
        .distinct
    end

    @diaries = @diaries.hilight if hilight
    @diaries = @diaries.where("record_at >= ?", since_date) if since_date.present?
    @diaries = @diaries.where("record_at <= ?", until_date) if until_date.present?
    @diaries = @diaries.where(record_at: date_range) if date_range.present?

    if words.present?
      words.each do |word|
        @diaries = @diaries.find_by_word(word)
      end
    end

    @diaries
  end

  def search_word_param
    @params.dig(:diary, :search_word)
  end

  def tag_param
    @params[:tag]
  end
end
