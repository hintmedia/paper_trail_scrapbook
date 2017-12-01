module PaperTrailScrapbook
  # Class UserJournal provides history for a user, optionally scoped by
  # object class and/or date range
  #
  # @author Jason Dinsmore <jason@dinjas.com>
  #
  class UserJournal
    def initialize(user, opts = {})
      @user_id  = String(user.id)
      @options  = opts

      @versions = PaperTrail::Version.where(query_params)
    end

    # Retries textual historical analysis of versions
    #
    # @return [String] analyzed versions
    #
    def story
      versions.map do |v|
        Chapter.new(v).story
      end.compact.join("\n\n")
    end

    private

    def query_params
      params = { whodunnit: user_id }
      return params if options.empty?

      params.merge(item_type: String(options.fetch(:klass)))
    end

    attr_reader :versions, :user_id, :options
  end
end
