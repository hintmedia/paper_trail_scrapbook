# frozen_string_literal: true

class Versions
  include Concord.new(:object)

  def versions
    filtered(object.versions | related_content).sort_by(&:created_at)
  end

  def related_content
    if object.respond_to?(:trailed_related_content)
      object.trailed_related_content.compact.flat_map(&:versions)
    else
      []
    end
  end

  def filtered(object_versions)
    if object.respond_to?(:version_filter)
      object_versions.select { |v| object.version_filter(v) }
    else
      object_versions
    end
  end

end
