# frozen_string_literal: true

class Fruit < ActiveRecord::Base
  has_paper_trail class_name: 'JsonVersion' if ENV['DB'] == 'postgres' || JsonVersion.table_exists?
end
