class SearchController < ApplicationController
  before_action :authenticate_user!
  WRAP_WORD_LENGTH = 30

  def top
    @search_word = params[:q]
    return if @search_word.blank?
    @g_search_word = @search_word

    records = Record.by_user_or_family(current_user).has_data.newer
    searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
    @result_records_size = searcher.result.size
    @result_diaries_size = current_user.diaries.find_by_word(@search_word).size
    @result_habitodos_size = current_user.habitodos.find_by_word(@search_word).size
    # @result_senses = current_user.senses.find_by_word(@search_word)
    @result_histories_size = current_family.all_histories.find_by_word(@search_word).size

    @page_title = 'サイト内検索'
    @no_header_margin = true
  end

  # 日記、こどもデータなどコンテンツごとのデータ読み込み
  def content
    @content_type = params[:content_type]
    @search_word = params[:q]

    source_data = case @content_type.to_sym
                   when :history
                     current_family.all_histories.find_by_word(@search_word).newer
                   when :habitodo
                     current_user.habitodos.find_by_word(@search_word)
                   when :diary
                     current_user.diaries.find_by_word(@search_word).newer
                   when :record
                     records = Record.by_user_or_family(current_user).has_data.newer.includes(:habit)
                     searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
                     searcher.result
                   else
                     raise 'no content_type'
                   end

    result_items = source_data.map { |obj| obj.search_result_items }
    result_items.each do |item|
      item[:highlighted] = highlight_text(item[:target_text].dup)
    end

    results = if @content_type.to_sym == :diary
                result_items.map { _1.slice(:id, :type, :highlighted, :title, :show_path) }
              else
                result_items.map { _1.slice(:id, :type, :highlighted, :title, :body, :show_path) }
              end

    render json: results
  end

  private

  def highlight_text(target_text)
    # TODO: htmlサニタイズ?
    @result_text = ''
    recursive(target_text)
    @result_text
  end

  # TODO: class化、Rspec
  def recursive(target_text)
    idx = target_text.index(/#{@search_word}/i)
    return if idx.blank?
    prev_word = target_text.slice!(0, idx)
    prev_word = prev_word.reverse.truncate(WRAP_WORD_LENGTH).reverse
    found_word = target_text.slice!(0, @search_word.length)
    next_word = target_text.slice(0, WRAP_WORD_LENGTH + 5).truncate(WRAP_WORD_LENGTH)
    @result_text += prev_word + "<span class='highlight'>#{found_word}</span>" + next_word
    recursive(target_text)
  end
end
