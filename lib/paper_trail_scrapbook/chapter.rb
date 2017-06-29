module PaperTrailScrapbook
  class Chapter
    include Concord.new(:version)

    UNKNOWN = '*the app*'.freeze

    # Single version historical analysis
    #
    #
    # @return [String] Human readable description of changes
    #
    def story
      "On #{whenn}, #{who} #{kind} the following #{model} information:".split.join(' ') + "\n#{changes}"
    end

    private

    def model
      version.item_type
    end

    def changes
      PaperTrailScrapbook::Changes.new(version).change_log
    end

    def who
      author = version.version_author
      if author
        if PaperTrailScrapbook.whodunnit_class
          PaperTrailScrapbook.whodunnit_class.find(author.to_i).to_s
        else
          author
        end
      else
        UNKNOWN
      end
    end

    def whenn
      version.created_at.strftime('%A, %d %b %Y at %l:%M %p')
    end

    def kind
      case version.event
      when 'create'
        'created'
      when 'update'
        'updated'
      when 'destroy'
        'destroyed'
      end
    end
  end
end
