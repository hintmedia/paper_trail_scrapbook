require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    DEFAULT_TIME_FORMAT = '%A, %d %b %Y at %l:%M %p'

    attr_accessor :whodunnit_class, :time_format

    def initialize
      @whodunnit_class = nil
      @time_format = DEFAULT_TIME_FORMAT
    end
  end
end
