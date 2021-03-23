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
        # Return the Array of changes for JSON packaging
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
      "On #{whenn}, #{who} #{kind} #{what}".squeeze(' ')
    end

    def what
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
