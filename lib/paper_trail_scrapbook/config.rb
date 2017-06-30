require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    attr_accessor :whodunnit_class

    def initialize
      @whodunnit_class = nil
    end
  end
end
