module PaperTrailScrapbook
  class LifeHistory
    def initialize(object)
      @versions = object.versions
    end

    def story
      versions.map do |v|
        Chapter.new(v).story
      end.join("\n\n")
    end

    private

    attr_reader :versions
  end
end
