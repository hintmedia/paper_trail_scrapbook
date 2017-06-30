require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    DEFAULT_TIME_FORMAT = '%A, %d %b %Y at %l:%M %p'.freeze
    DEFAULT_EVENTS      = { 'create'  => 'created',
                            'update'  => 'updated',
                            'destroy' => 'destroyed' }.freeze

    SCRUB_COLUMNS = %w[updated_at created_at id].freeze

    attr_accessor :whodunnit_class,
                  :time_format,
                  :events,
                  :scrub_columns,
                  :drop_id_suffix

    def initialize
      @whodunnit_class = nil
      @time_format     = DEFAULT_TIME_FORMAT
      @events          = DEFAULT_EVENTS
      @scrub_columns   = SCRUB_COLUMNS
      @drop_id_suffix  = true
    end
  end
end
