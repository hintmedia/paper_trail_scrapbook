# frozen_string_literal: true

class Versions
  include Concord.new(:object)

  def versions
    versions = object.versions

    if object.respond_to?(:trailed_related_content)
      object.trailed_related_content.compact.each do |trc|
        versions |= trc.versions
      end
    end

    if object.respond_to?(:version_filter)
      versions.select! { |v| object.version_filter(v) }
    end

    versions.sort_by(&:created_at
  end

end
