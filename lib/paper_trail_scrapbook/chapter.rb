module PaperTrailScrapbook
  # Class Chapter provides single version history analysis
  #
  # @author Timothy Chambers <tim@possibilogy.com>
  #
  class Chapter
    include Concord.new(:version)
    include Adamantium::Flat

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
      "On #{whenn}, #{who} #{kind} the following #{model} info:".squeeze(' ')
    end

    def model
      version.item_type
    end

    def create?
      event.eql?('create')
    end

    def changes
      Changes.new(version).change_log
    end

    def who
      author = version.version_author
      if author
        if whodunnit_class
          if whodunnit_class.method_defined?(:to_whodunnit)
            whodunnit_class.find(author).to_whodunnit
          else
            whodunnit_class.find(author).to_s
          end
        else
          author
        end
      else
        config.unknown_whodunnit
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
      config.events[event] ||
        raise(ArgumentError, "incorrect event:#{event}")
    end
  end
end
