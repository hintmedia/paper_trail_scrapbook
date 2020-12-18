# frozen_string_literal: true

class Versions
  include Concord.new(:object)

  def versions
    sorted(filtered(with_related(object.versions)))
  end

  def with_related(object_versions)
    unless object.respond_to?(:trailed_related_content)
      return object_versions
    end

    object_versions | object.trailed_related_content.compact.map(&:versions)
  end

  def filtered(object_versions)
    unless object.respond_to?(:version_filter)
      return object_versions
    end

    object_versions.select { |v| object.version_filter(v) }
  end

  def sorted(object_versions)
    object_versions.sort_by(&:created_at)
  end

end
