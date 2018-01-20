require_relative 'version_helpers'

module PaperTrailScrapbook
  # Class JournalEntry provides single version history analysis
  #
  # @author Jason Dinsmore <jason@dinjas.com>
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

      "#{preface}\n#{updates}"
    end

    private

    def preface
      "On #{whenn}, #{kind} #{model}[#{model_id}]:".squeeze(' ')
    end
  end
end
