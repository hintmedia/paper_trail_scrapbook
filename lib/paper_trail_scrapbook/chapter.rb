require_relative 'version_helpers'

module PaperTrailScrapbook
  # Class Chapter provides single version history analysis
  #
  # @author Timothy Chambers <tim@possibilogy.com>
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
      return unless create? || updates.present? || !config.filter_non_changes

      "#{preface}\n#{updates}"
    end

    private

    def preface
      "On #{whenn}, #{who} #{kind} the following #{model} info:".squeeze(' ')
    end

  end
end
