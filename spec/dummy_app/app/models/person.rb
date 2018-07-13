# frozen_string_literal: true

class Person < ActiveRecord::Base
  has_many :authorships, foreign_key: :author_id, dependent: :destroy
  has_many :books, through: :authorships
  belongs_to :mentor, class_name: 'Person', foreign_key: :mentor_id
  has_paper_trail

  def to_s
    name
  end
end
