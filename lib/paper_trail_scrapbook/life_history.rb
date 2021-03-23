# frozen_string_literal: true

module PaperTrailScrapbook
  # Class LifeHistory provides Full multi version history
  #
  # @author Timothy Chambers <tim@hint.io>
  #
  class LifeHistory
    def initialize(object)
      @object   = object
      @versions = Versions.new(object).versions
    end

    # Retries textual historical analysis of versions
    #
    # @return [String] analyzed versions
    #
    def story
      x = versions.map do |v|
        if primary?(v)
          Chapter
        else
          SecondaryChapter
        end.new(v).story
      end.compact

      x.reverse! if PaperTrailScrapbook.config.recent_first

      case PaperTrailScrapbook.config.format
      when :json
        # Return the Array of changes for JSON packaging
        x
      when :markdown
        x.join("\n\n")
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{PaperTrailScrapbook.config.format} default to :markdown")
        x.join("\n\n")
      end
    end

    private

    def primary?(version)
      version.item_type.eql?(object.class.name) &&
        version.item_id.equal?(object.id)
    end

    attr_reader :object, :versions
  end
end
