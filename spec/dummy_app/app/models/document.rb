# frozen_string_literal: true

class Document < ActiveRecord::Base
  has_paper_trail(
    versions: { name: :paper_trail_versions },
    on: %i[create update]
  )
end
