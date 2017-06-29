module PaperTrailScrapbook
  class Changes

    include Concord.new(:version)

    def initialize(*)
      super

      build_associations
    end

    BULLET = ' •'

    def change_log
      changes.map { |k, v| digest(k, v) }.join("\n").gsub('_id:', ':')
    end

    private

    def digest(k, v)
      old, new = v
      "#{BULLET} #{k}: " + if old.nil?
                             "#{find_value(k, new)} added"
                           elsif new.nil?
                             "#{find_value(k, old)} was *removed*"
                           else
                             "#{find_value(k, old)} -> #{find_value(k, new)}"
                           end
    end

    def find_value(key, value)
      return value.to_s unless assoc.key?(key)

      return '*empty*' unless value

      if key == 'held_advertiser_id'
        p assoc
      end

      assoc[key].find(value).to_s + "[#{value}]" rescue "*not found*[#{value}]"
    end

    def assoc_klass(name)
      Object.const_get(name.to_s.classify)
    rescue
      Object.const_set(name.to_s.classify, Class.new)
    end

    def klass
      assoc_klass(version.item_type)
    end

    def build_associations
      @assoc ||= Hash[klass
                        .reflect_on_all_associations
                        .select { |a| a.macro == :belongs_to }
                        .map { |x| [x.foreign_key.to_s, assoc_klass(x.name)] }]
    end

    def object_changes
      version.object_changes
    end

    def changes
      @chs ||= object_changes ? YAML
                                  .load(object_changes)
                                  .except('updated_at', 'created_at ', 'id') : {}
    end

    attr_reader :assoc, :chs
  end
end
