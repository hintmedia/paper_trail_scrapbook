# frozen_string_literal: true

class Versions
  include Concord.new(:object)

  def versions
    sorted(filtered(object.versions | related_content))
  end

  def related_content
    if object.respond_to?(:trailed_related_content)
      object.trailed_related_content.compact.map(&:versions)
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

  def sorted(object_versions)
    object_versions.sort_by(&:created_at)
  end

end
