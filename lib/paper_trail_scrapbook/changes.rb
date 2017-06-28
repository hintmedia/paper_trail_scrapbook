module PaperTrailScrapbook
  class Changes

    include Concord.new(:version)

    def change_log
      changes.map{ |k,v| digest(k,v)}.join("\n")
    end

    private

    def digest(k,v)
      old, new = v
      "#{bullet} #{k}: " + if old.nil?
                             new.to_s
                           else
                             "#{old} -> #{new}"
                           end
    end

    def changes
      YAML.load(version.object_changes).except('created_at', 'id')
    end
  end
end
