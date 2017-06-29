require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    def initialize
      # Variables which affect all threads, whose access is synchronized.
      @mutex = Mutex.new
    end
  end
end
