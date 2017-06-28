module PaperTrailScrapbook
  class Chapter
    include Concord.new(:version)

    def story
      "On #{whenn}, #{who} #{kind} the following information:\n#{changes}"
    end

    private

    def changes
      p version.object_changes
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
        'Someone'
      end
    end

    def whenn
      version.created_at.strftime("%A, %d %b %Y %l:%M %p")
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
