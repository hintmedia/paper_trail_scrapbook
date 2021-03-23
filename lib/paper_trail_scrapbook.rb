# frozen_string_literal: true

require 'adamantium'
require 'concord'
require 'equalizer'
require 'ice_nine'
require 'pathname'
require 'paper_trail_scrapbook/config'
require 'paper_trail_scrapbook/chapter'
require 'paper_trail_scrapbook/changes'
require 'paper_trail_scrapbook/journal_entry'
require 'paper_trail_scrapbook/life_history'
require 'paper_trail_scrapbook/secondary_chapter'
require 'paper_trail_scrapbook/user_journal'
require 'paper_trail_scrapbook/version'
require 'paper_trail_scrapbook/version_helpers'
require 'paper_trail_scrapbook/versions'

# Library namespace
#
# @api private
module PaperTrailScrapbook
  class << self
    # Returns PaperTrailScrapbook's configuration object.
    # @api private
    def config
      @config ||= PaperTrailScrapbook::Config.instance
      yield @config if block_given?
      @config
    end
    alias configure config
  end

  def self.logger
    @@logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end

  def self.logger=(logger)
    @@logger = logger
  end
end
