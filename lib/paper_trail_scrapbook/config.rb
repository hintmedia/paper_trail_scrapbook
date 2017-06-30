require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    DEFAULT_TIME_FORMAT = '%A, %d %b %Y at %l:%M %p'.freeze
    DEFAULT_EVENTS      = { 'create'  => 'created',
                            'update'  => 'updated',
                            'destroy' => 'destroyed' }.freeze

    attr_accessor :whodunnit_class, :time_format, :events

    def initialize
      @whodunnit_class = nil
      @time_format     = DEFAULT_TIME_FORMAT
      @events          = DEFAULT_EVENTS
    end
  end
end
