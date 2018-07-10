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
      return unless tell_story?(updates)

      [preface, (updates unless destroy?)].compact.join("\n")
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
