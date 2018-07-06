module PaperTrailScrapbook
  # Class LifeHistory provides Full multi version history
  #
  # @author Timothy Chambers <tim@possibilogy.com>
  #
  class LifeHistory
    def initialize(object)
      @versions = object.versions

      if object.respond_to?(:trailed_related_content)
        object.trailed_related_content.each do |trc|
          @versions |= trc.versions
        end
      end

      @versions.to_a.sort_by!(&:created_at)
    end

    # Retries textual historical analysis of versions
    #
    # @return [String] analyzed versions
    #
    def story
      versions.map do |v|
        Chapter.new(v).story
      end.compact.join("\n\n")
    end

    private

    attr_reader :versions
  end
end
