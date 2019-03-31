# frozen_string_literal: true

module PaperTrailScrapbook
  # Class Changes provides detailed attribute by attribute analysis
  #
  # @author Timothy Chambers <tim@possibilogy.com>
  #
  class Changes
    include Concord.new(:version)
    include Adamantium::Flat
    include PaperTrailScrapbook::VersionHelpers

    delegate :object_changes, to: :version

    def initialize(*)
      super
      build_associations
      changes
    end

    BULLET = ' •'

    # Attribute change analysis
    #
    #
    # @return [String] Summary analysis of changes
    #
    def change_log
      text = changes
             .map { |k, v| digest(k, v) }
             .compact
             .join("\n")

      text = text.gsub(' id:', ':') if PaperTrailScrapbook.config.drop_id_suffix
      text
    end

    private

    def polymorphic?(x)
      x.to_s.start_with?('*')
    end

    def digest(key, values)
      old, new = values
      return if old.nil? && (new.nil? || new.eql?('')) || (old == new && !creating?)

      "#{BULLET} #{key.tr('_', ' ')}: #{detailed_analysis(key, new, old)}"
    end

    def detailed_analysis(key, new, old)
      if creating?
        find_value(key, new).to_s
      elsif old.nil?
        "#{find_value(key, new)} added"
      elsif new.nil?
        "#{find_value(key, old)} was *removed*"
      else
        "#{find_value(key, old)} -> #{find_value(key, new)}"
      end
    end

    def creating?
      version.event.eql?('create')
    end

    def find_value(key, value)
      return value.to_s unless build_associations.key?(key)

      return '*empty*' unless value

      begin
        assoc_target(key).find(value).to_s.to_s + "[#{value}]"
      rescue StandardError
        "*not found*[#{value}]"
      end
    end

    def assoc_target(key)
      x = build_associations[key]
      return x unless polymorphic?(x)

      # try object changes to see if the belongs_to class is specified
      latest_class = changes[x[1..-1] + '_type'].last

      if latest_class.nil? && create?
        # try the db default class
        # for creates where the object changes do not specify this it
        # is most likely because the default ==  type selected so
        # the default was not changed and therefore is not in
        # object changes
        orig_instance = Object.const_get(version.item_type.classify).new
        latest_class = orig_instance[(x[1..-1] + '_type').to_sym]
      end
      
      Object.const_get(latest_class.classify)
    end

    def assoc_klass(name, options = {})
      direct_class = options[:class_name]
      poly = options[:polymorphic]

      return direct_class if !poly && direct_class && !direct_class.is_a?(String)

      poly ? '*' + name.to_s : Object.const_get((direct_class || name.to_s).classify)
    rescue StandardError
      Object.const_set(name.to_s.classify, Class.new)
    end

    def klass
      assoc_klass(version.item_type)
    end

    def build_associations
      @build_associations ||=
        Hash[
          klass
        .reflect_on_all_associations
        .select { |a| a.macro.equal?(:belongs_to) }
        .map { |x| [x.foreign_key.to_s, assoc_klass(x.name, x.options)] }
        ]
    end

    def changes
      @changes ||= if object_changes
                     YAML
                       .load(object_changes)
                       .except(*PaperTrailScrapbook.config.scrub_columns)
                   else
                     {}
                   end
    end
  end
end
