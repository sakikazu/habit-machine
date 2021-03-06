class SearchController < ApplicationController
  before_action :authenticate_user!
  WRAP_WORD_LENGTH = 30

  def top
    @search_word = params[:q]
    if @search_word.blank?
      render plain: "検索ワードを入力してください"
      return
    end
    @g_search_word = @search_word

    records = Record.user_by(current_user).has_data.newer
    searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
    @result_records_size = searcher.result.size
    @result_diaries_size = current_user.diaries.find_by_word(@search_word).size
    @result_habitodos_size = current_user.habitodos.find_by_word(@search_word).size
    # @result_senses = current_user.senses.find_by_word(@search_word)

    @page_title = 'サイト内検索'
    @no_header_margin = true
  end

  def content
    @content_type = params[:content_type]
    @search_word = params[:q]

    source_data = case @content_type.to_sym
                   when :habitodo
                     current_user.habitodos.find_by_word(@search_word)
                   when :diary
                     current_user.diaries.find_by_word(@search_word).newer
                   when :record
                     records = Record.user_by(current_user).has_data.newer.includes(:habit)
                     searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
                     searcher.result
                   else
                     raise 'no content_type'
                   end

    @results = source_data.map { |obj| obj.search_result_items }
    @results.each_with_index do |result, idx|
      # TODO: htmlサニタイズ?
      @result_text = ''
      recursive(result[:target_text].dup)
      result['highlighted'] = @result_text
    end

    render json: @results
  end

  private

  # TODO: class化、Rspec
  def recursive(target_text)
    idx = target_text.index(@search_word)
    return if idx.blank?
    prev_word = target_text.slice!(0, idx)
    prev_word = prev_word.reverse.truncate(WRAP_WORD_LENGTH).reverse
    found_word = target_text.slice!(0, @search_word.length)
    next_word = target_text.slice(0, WRAP_WORD_LENGTH + 5).truncate(WRAP_WORD_LENGTH)
    @result_text += prev_word + "<span class='highlight'>#{found_word}</span>" + next_word
    recursive(target_text)
  end
end
