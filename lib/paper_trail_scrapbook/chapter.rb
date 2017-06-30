module PaperTrailScrapbook
  # Class Chapter provides single version history analysis
  #
  # @author Timothy Chambers <tim@possibilogy.com>
  #
  class Chapter
    include Concord.new(:version)

    UNKNOWN = '*the app*'.freeze

    # Single version historical analysis
    #
    # @return [String] Human readable description of changes
    #
    def story
      "#{preface}\\n#{changes}"
    end

    private

    def preface
      "On #{whenn}, #{who} #{kind} the following #{model} information:".squeeze(' ')
    end

    def model
      version.item_type
    end

    def changes
      Changes.new(version).change_log
    end

    def who
      author = version.version_author
      if author
        if whodunnit_class
          whodunnit_class.find(author).to_s
        else
          author
        end
      else
        UNKNOWN
      end
    end

    def whodunnit_class
      config.whodunnit_class
    end

    def config
      PaperTrailScrapbook.config
    end

    def whenn
      version.created_at.strftime(config.time_format)
    end

    def kind
      config.events[version.event] ||
        raise(ArgumentError, "incorrect event:#{version.event}")
    end
  end
end
