# frozen_string_literal: true

module PaperTrailScrapbook
  class Versions
    include Concord.new(:object)

    def versions
      filtered(object.versions | related_content).sort_by(&:created_at)
    end

    def related_content
      unless object.respond_to?(:trailed_related_content)
        return []
      end

      object.trailed_related_content.compact.flat_map(&:versions)
    end

    def filtered(object_versions)
      unless object.respond_to?(:version_filter)
        return object_versions
      end

      object_versions.select { |v| object.version_filter(v) }
    end

  end

end
