# frozen_string_literal: true

require "json"
require "time"

module YoutubeArchiver
  class Formatter
    def self.build_payload(video:, source:, threads:)
      {
        fetched_at: Time.now.iso8601,
        source: {
          input: source[:input],
          resolved_video_id: source[:video_id],
          resolved_url: source[:url]
        },
        video: video,
        summary: {
          total_threads: threads.size,
          total_comments_including_replies: threads.sum { |thread| 1 + thread[:replies].size },
          total_replies: threads.sum { |thread| thread[:replies].size }
        },
        threads: threads
      }
    end

    def self.to_pretty_json(payload)
      JSON.pretty_generate(payload)
    end

    def self.to_markdown(payload)
      video = payload[:video] || payload["video"]
      summary = payload[:summary] || payload["summary"]
      threads = payload[:threads] || payload["threads"]
      fetched_at = payload[:fetched_at] || payload["fetched_at"]
      source = payload[:source] || payload["source"]

      lines = []
      lines << "## Video"
      lines << ""
      lines << "- title: #{video[:title] || video['title']}"
      lines << "- video_id: #{video[:video_id] || video['video_id']}"
      lines << "- channel_title: #{video[:channel_title] || video['channel_title']}"
      lines << "- published_at: #{video[:published_at] || video['published_at']}"
      lines << "- original_input: #{source[:input] || source['input']}"
      lines << "- resolved_url: #{source[:resolved_url] || source['resolved_url']}"
      lines << "- fetched_at: #{fetched_at}"
      lines << ""
      lines << "## Summary"
      lines << ""
      lines << "- total_threads: #{summary[:total_threads] || summary['total_threads']}"
      lines << "- total_replies: #{summary[:total_replies] || summary['total_replies']}"
      lines << "- total_comments_including_replies: #{summary[:total_comments_including_replies] || summary['total_comments_including_replies']}"
      lines << ""
      lines << "## Threads"
      lines << ""

      threads.each_with_index do |thread, index|
        top = thread[:top_level_comment] || thread["top_level_comment"]
        replies = thread[:replies] || thread["replies"]

        lines << "### Thread #{index + 1}"
        lines << ""
        lines << "- top_level_comment:"
        lines << "  - comment_id: #{top[:comment_id] || top['comment_id']}"
        lines << "  - author: #{sanitize_inline(top[:author_display_name] || top['author_display_name'])}"
        lines << "  - like_count: #{top[:like_count] || top['like_count']}"
        lines << "  - published_at: #{top[:published_at] || top['published_at']}"
        lines << "  - total_reply_count: #{top[:total_reply_count] || top['total_reply_count']}"
        lines << "  - text: |"
        indent_block(lines, top[:text] || top['text'], 6)
        lines << ""

        if replies.empty?
          lines << "- replies: []"
          lines << ""
          next
        end

        lines << "- replies:"
        replies.each do |reply|
          lines << "  - comment_id: #{reply[:comment_id] || reply['comment_id']}"
          lines << "    parent_id: #{reply[:parent_id] || reply['parent_id']}"
          lines << "    author: #{sanitize_inline(reply[:author_display_name] || reply['author_display_name'])}"
          lines << "    like_count: #{reply[:like_count] || reply['like_count']}"
          lines << "    published_at: #{reply[:published_at] || reply['published_at']}"
          lines << "    text: |"
          indent_block(lines, reply[:text] || reply['text'], 8)
        end
        lines << ""
      end

      lines.join("\n")
    end

    def self.indent_block(lines, text, spaces)
      prefix = " " * spaces
      text.to_s.split("\n").each do |line|
        lines << "#{prefix}#{line}"
      end
    end

    def self.sanitize_inline(text)
      text.to_s.gsub("\n", " ").strip
    end
  end
end
