module PaperTrailScrapbook
  # Class Chapter provides single version history analysis
  #
  # @author Timothy Chambers <tim@possibilogy.com>
  #
  class SecondaryChapter < Chapter

    private

    def item_id
      "[#{model_id}]"
    end

  end
end
