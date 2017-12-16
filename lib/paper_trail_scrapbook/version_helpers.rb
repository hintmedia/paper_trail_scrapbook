module PaperTrailScrapbook
  # Module VersionHelpers provides methods for extracting common information
  # from a version or PaperTrailScrapbook config
  module VersionHelpers
    delegate :event, to: :version

    def model
      version.item_type
    end

    def model_id
      version.item_id
    end

    def create?
      event.eql?('create')
    end

    def changes
      Changes.new(version).change_log
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
  end
end
