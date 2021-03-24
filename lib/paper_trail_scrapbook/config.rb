# frozen_string_literal: true

require 'singleton'

module PaperTrailScrapbook
  # Global configuration affecting all threads.
  class Config
    include Singleton

    DEFAULT_TIME_FORMAT = '%A, %d %b %Y at %l:%M %p'
    DEFAULT_EVENTS      = { 'create' => 'created',
                            'update' => 'updated',
                            'destroy' => 'destroyed' }.freeze

    SCRUB_COLUMNS     = %w[updated_at created_at id].freeze
    UNKNOWN_WHODUNNIT = '*the app*'
    FORMATS = %i[
      markdown
      json
    ].freeze

    attr_accessor :whodunnit_class,
                  :time_format,
                  :events,
                  :scrub_columns,
                  :drop_id_suffix,
                  :unknown_whodunnit,
                  :invalid_whodunnit,
                  :filter_non_changes,
                  :recent_first,
                  :format

    def initialize
      @whodunnit_class    = nil
      @time_format        = DEFAULT_TIME_FORMAT
      @events             = DEFAULT_EVENTS
      @scrub_columns      = SCRUB_COLUMNS
      @unknown_whodunnit  = UNKNOWN_WHODUNNIT
      @invalid_whodunnit  = proc { |w| "*missing (#{w})*" }
      @drop_id_suffix     = true
      @filter_non_changes = true
      @recent_first       = false
      @format             = :markdown
    end
  end
end
