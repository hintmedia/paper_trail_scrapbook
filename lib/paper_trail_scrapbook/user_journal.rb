# frozen_string_literal: true

module PaperTrailScrapbook
  # Class UserJournal provides history for a user, optionally scoped by
  # object class and/or date range
  #
  # @author Jason Dinsmore <jason@hint.io>
  #
  class UserJournal
    include Adamantium::Flat

    def initialize(user, opts = {})
      @user     = user
      @user_id  = String(user.id)
      @options  = opts
      @starts   = options[:start] || Time.at(0).in_time_zone
      @ends     = options[:end] || Time.current.in_time_zone

      @versions = PaperTrail::Version.where(query_params)
    end

    # Retries textual historical analysis of versions
    #
    # @return [String || Hash ] analyzed versions
    #
    def story
      s = versions.map do |v|
        JournalEntry.new(v).story
      end.compact

      s.reverse! if PaperTrailScrapbook.config.recent_first

      case PaperTrailScrapbook.config.format
      when :json
        # Return the Array of changes for JSON packaging
        { "#{preface}": (s.presence || ['No history']) }
      when :markdown
        s.join("\n\n")
        "#{preface}#{s.presence || 'No history'}"
      else
        PaperTrailScrapbook.logger.debug("Unknown formatting #{PaperTrailScrapbook.config.format} default to :markdown")
        s.join("\n\n")
        "#{preface}#{s.presence || 'No history'}"
      end
    end

    private

    def preface
      "Between #{when_range}, #{user} made the following #{what} changes:\n\n"
        .squeeze(' ')
    end

    def query_params
      params = { whodunnit: user_id }
      return params if options.empty?

      params.merge(item_type: what,
                   created_at: starts..ends)
            .delete_if { |_, v| v.presence.nil? }
    end

    def time_format
      PaperTrailScrapbook.config.time_format
    end

    def what
      String(options.fetch(:klass, nil)).presence
    end

    def when_range
      "#{starts.strftime(time_format)} and #{ends.strftime(time_format)}"
    end

    attr_reader :user, :user_id, :versions, :options, :starts, :ends
  end
end
