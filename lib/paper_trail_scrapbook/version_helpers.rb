# frozen_string_literal: true

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

    def destroy?
      event.eql?('destroy')
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
      return config.unknown_whodunnit unless author
      return author unless whodunnit_class

      whodunnit_instance(author)
    end

    def whodunnit_class
      config.whodunnit_class
    end

    def whodunnit_instance(author)
      instance = begin
        whodunnit_class.find(author)
      rescue StandardError
        config.invalid_whodunnit.call(author)
      end

      return instance.to_whodunnit if instance.respond_to?(:to_whodunnit)

      instance.to_s
    end
  end
end
