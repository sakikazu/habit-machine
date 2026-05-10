# frozen_string_literal: true

require "cgi"
require "json"
require "time"
require "uri"
require "google/apis/youtube_v3"

module YoutubeArchiver
  class Fetcher
    Youtube = Google::Apis::YoutubeV3

    DEFAULT_MAX_THREADS = 1_000
    THREADS_PAGE_SIZE = 100
    REPLIES_PAGE_SIZE = 100

    def initialize(api_key:)
      @service = Youtube::YouTubeService.new
      @service.key = api_key
    end

    def self.extract_video_id(url_or_id)
      return url_or_id if url_or_id.match?(/\A[\w-]{11}\z/)

      uri = URI.parse(url_or_id)

      if uri.host&.include?("youtu.be")
        candidate = uri.path.delete_prefix("/").split("/").first
        return candidate if candidate&.match?(/\A[\w-]{11}\z/)
      end

      params = CGI.parse(uri.query.to_s)
      video_id = params["v"]&.first
      return video_id if video_id&.match?(/\A[\w-]{11}\z/)

      segments = uri.path.split("/")
      shorts_index = segments.index("shorts")
      if shorts_index && segments[shorts_index + 1]
        candidate = segments[shorts_index + 1]
        return candidate if candidate.match?(/\A[\w-]{11}\z/)
      end

      nil
    rescue URI::InvalidURIError
      nil
    end

    def extract_video_id(url_or_id)
      self.class.extract_video_id(url_or_id)
    end

    def fetch_video(video_id)
      response = @service.list_videos("snippet,statistics", id: video_id)
      item = response.items&.first
      raise "動画が見つかりませんでした: #{video_id}" unless item

      {
        video_id: item.id,
        title: item.snippet&.title,
        channel_title: item.snippet&.channel_title,
        published_at: iso8601_or_nil(item.snippet&.published_at),
        comment_count: item.statistics&.comment_count&.to_i,
        view_count: item.statistics&.view_count&.to_i,
        like_count: item.statistics&.like_count&.to_i
      }
    end

    def fetch_threads(video_id:, max_threads: DEFAULT_MAX_THREADS, order: "time")
      page_token = nil
      threads = []
      fetched_top_level = 0

      loop do
        break if fetched_top_level >= max_threads

        remaining = max_threads - fetched_top_level
        page_size = [THREADS_PAGE_SIZE, remaining].min

        response = @service.list_comment_threads(
          "snippet,replies",
          video_id: video_id,
          max_results: page_size,
          order: order,
          page_token: page_token,
          text_format: "plainText"
        )

        response.items.each do |item|
          top = item.snippet.top_level_comment

          embedded_replies = Array(item.replies&.comments).map do |reply|
            reply_to_hash(reply)
          end

          all_replies =
            if embedded_replies.size < item.snippet.total_reply_count.to_i
              fetch_all_replies(parent_comment_id: top.id)
            else
              embedded_replies
            end

          threads << {
            top_level_comment: top_level_to_hash(
              top,
              total_reply_count: item.snippet.total_reply_count.to_i
            ),
            replies: all_replies
          }

          fetched_top_level += 1
          break if fetched_top_level >= max_threads
        end

        break if response.next_page_token.nil? || fetched_top_level >= max_threads
        page_token = response.next_page_token
      end

      threads
    end

    private

    def fetch_all_replies(parent_comment_id:)
      page_token = nil
      replies = []

      loop do
        response = @service.list_comments(
          "snippet",
          parent_id: parent_comment_id,
          max_results: REPLIES_PAGE_SIZE,
          page_token: page_token,
          text_format: "plainText"
        )

        response.items.each do |item|
          replies << reply_to_hash(item)
        end

        break if response.next_page_token.nil?
        page_token = response.next_page_token
      end

      replies
    end

    def top_level_to_hash(comment, total_reply_count:)
      snippet = comment.snippet

      {
        comment_id: comment.id,
        parent_id: nil,
        kind: "top_level",
        author_display_name: snippet.author_display_name,
        author_channel_id: snippet.author_channel_id&.value,
        text: snippet.text_display,
        like_count: snippet.like_count.to_i,
        published_at: iso8601_or_nil(snippet.published_at),
        updated_at: iso8601_or_nil(snippet.updated_at),
        total_reply_count: total_reply_count
      }
    end

    def reply_to_hash(comment)
      snippet = comment.snippet

      {
        comment_id: comment.id,
        parent_id: snippet.parent_id,
        kind: "reply",
        author_display_name: snippet.author_display_name,
        author_channel_id: snippet.author_channel_id&.value,
        text: snippet.text_display,
        like_count: snippet.like_count.to_i,
        published_at: iso8601_or_nil(snippet.published_at),
        updated_at: iso8601_or_nil(snippet.updated_at)
      }
    end

    def iso8601_or_nil(value)
      value&.respond_to?(:iso8601) ? value.iso8601 : value&.to_s
    end
  end
end
