# frozen_string_literal: true

require_relative 'version_helpers'

module PaperTrailScrapbook
  # Class Chapter provides single version history analysis
  #
  # @author Timothy Chambers <tim@hint.io>
  #
  class Chapter
    include Concord.new(:version)
    include Adamantium::Flat
    include PaperTrailScrapbook::VersionHelpers

    # Single version historical analysis
    #
    # @return [String] Human readable description of changes
    #
    def story
      updates = changes
      return unless tell_story?(updates)

      chapter_story = [preface, (updates unless destroy?)]

      case PaperTrailScrapbook.config.format
      when :json
        chapter_story
      when :markdown
        chapter_story.compact.join("\n")
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{PaperTrailScrapbook.config.format} default to :markdown")
        chapter_story.compact.join("\n")
      end
    end

    private

    def preface
      case format
      when :json
        json_preface
      when :markdown
        markdown_preface
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{format} default to :markdown")
        markdown_preface
      end
    end

    def what
      case PaperTrailScrapbook.config.format
      when :json
        json_what
      when :markdown
        markdown_preface
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{PaperTrailScrapbook.config.format} default to :markdown")
        markdown_preface
      end
    end

    def markdown_preface
      "On #{whenn}, #{who} #{kind} #{what}".squeeze(' ')
    end

    def markdown_what
      if destroy?
        "#{model}#{item_id}"
      else
        "the following #{model}#{item_id} info:"
      end
    end

    def item_id; end

    def tell_story?(updates)
      create? || destroy? || updates.present? || !config.filter_non_changes
    end
  end
end
