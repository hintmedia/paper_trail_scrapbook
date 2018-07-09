module PaperTrailScrapbook
  # Class SecondaryChapter provides single version history analysis for data
  # related to the main subject
  #
  class SecondaryChapter < Chapter

    private

    def item_id
      "[#{model_id}]"
    end

  end
end
