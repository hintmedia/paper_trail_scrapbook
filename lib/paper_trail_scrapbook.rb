require 'adamantium'
require 'concord'
require 'digest/sha1'
require 'equalizer'
require 'ice_nine'
require 'morpher'
require 'open3'
require 'pathname'
require 'set'
require 'paper_trail_scrapbook/config'
require 'paper_trail_scrapbook/chapter'
require 'paper_trail_scrapbook/changes'
require 'paper_trail_scrapbook/life_history'
require 'paper_trail_scrapbook/version'

# Library namespace
#
# @api private
module PaperTrailScrapbook

  class << self

    # Sets class associated with PaperTrail.whodunnit
    # @api public
    def whodunnit_class=(value)
      paper_trail_scrapbook_store[:whodunnit_class] = value
    end

    # class responsible for any changes that occur.
    #
    # @api public
    def whodunnit_class
      paper_trail_scrapbook_store[:whodunnit_class]
    end

    # Thread-safe hash to hold PaperTrailScrapbook's data. Initializing with needed
    # default values.
    # @api private
    def paper_trail_scrapbook_store
      RequestStore.store[:paper_trail_scrapbook] ||= {  }
    end

    # Returns PaperTrailScrapbook's configuration object.
    # @api private
    def config
      @config ||= PaperTrailScrapbook::Config.instance
      yield @config if block_given?
      @config
    end
    alias configure config

    def version
      VERSION::STRING
    end
  end
end
