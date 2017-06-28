require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton
    attr_accessor :whodunnit_class

    def initialize
      # Variables which affect all threads, whose access is synchronized.
      @mutex = Mutex.new

      @whodunnit_class = nil
    end
  end
end
