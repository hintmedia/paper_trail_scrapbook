# frozen_string_literal: true

require_relative 'version_helpers'

module PaperTrailScrapbook
  # Class JournalEntry provides single version history analysis
  #
  # @author Jason Dinsmore <jason@hint.io>
  #
  class JournalEntry
    include Concord.new(:version)
    include Adamantium::Flat
    include PaperTrailScrapbook::VersionHelpers

    delegate :event, to: :version

    # Single version historical analysis
    #
    # @return [String] Human readable description of changes
    #
    def story
      updates = changes
      return unless create? || updates.present? || !config.filter_non_changes

      case PaperTrailScrapbook.config.format
      when :json
        # Return the Array of changes for JSON packaging
        { "#{preface}": updates }
      when :markdown
        "#{preface}\n#{updates}"
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{PaperTrailScrapbook.config.format} default to :markdown")
        "#{preface}\n#{updates}"
      end
    end

    private

    def preface
      "On #{whenn}, #{kind} #{model}[#{model_id}]:".squeeze(' ')
    end
  end
end
