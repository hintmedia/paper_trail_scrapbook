# frozen_string_literal: true

module PaperTrailScrapbook
  # Fetches available versions and related version info
  # Provides filtering
  class Versions
    include Concord.new(:object)

    def versions
      filtered(object.versions | related_content).sort_by(&:created_at)
    end

    def related_content
      return [] unless object.respond_to?(:trailed_related_content)

      object.trailed_related_content.compact.flat_map(&:versions)
    end

    def filtered(object_versions)
      return object_versions unless object.respond_to?(:version_filter)

      object_versions.select { |v| object.version_filter(v) }
    end
  end
end
