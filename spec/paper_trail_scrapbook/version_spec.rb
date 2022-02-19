# frozen_string_literal: true

module PaperTrailScrapbook
  ::RSpec.describe VERSION do
    it { expect(VERSION).to be_kind_of(String) }
  end
end
