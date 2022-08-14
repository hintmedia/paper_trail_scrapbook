# frozen_string_literal: true

class Fruit < ActiveRecord::Base
  has_paper_trail versions: { class_name: 'JsonVersion' } if ENV['DATABASE_HOST'] == 'postgres' || JsonVersion.table_exists?
end
