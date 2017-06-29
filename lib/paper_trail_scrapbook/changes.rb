module PaperTrailScrapbook
  class Changes
    include Concord.new(:version)

    def initialize(*)
      super

      build_associations
    end

    BULLET = ' •'.freeze

    def change_log
      changes.map { |k, v| digest(k, v) }.compact.join("\n").gsub('_id:', ':')
    end

    private

    def digest(k, v)
      return if old.nil? && (new.nil? || new.empty?)

      old, new = v
      "#{BULLET} #{k}: " + if creating?
                             find_value(k, new).to_s
                           elsif old.nil?
                             "#{find_value(k, new)} added"
                           elsif new.nil?
                             "#{find_value(k, old)} was *removed*"
                           else
                             "#{find_value(k, old)} -> #{find_value(k, new)}"
                           end
    end

    def creating?
      version.event.eql?('create')
    end

    def find_value(key, value)
      return value.to_s unless assoc.key?(key)

      return '*empty*' unless value

      begin
        assoc[key].find(value).to_s + "[#{value}]"
      rescue
        "*not found*[#{value}]"
      end
    end

    def assoc_klass(name, options = {})
      direct_class = options[:class_name]
      return direct_class if direct_class && !direct_class.is_a?(String)

      Object.const_get((direct_class || name.to_s).classify)
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
                        .map { |x| [x.foreign_key.to_s, assoc_klass(x.name, x.options)] }]
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
