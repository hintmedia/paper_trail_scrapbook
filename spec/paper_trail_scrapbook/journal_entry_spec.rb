# frozen_string_literal: true

require 'spec_helper'
require './lib/paper_trail_scrapbook/journal_entry'

RSpec.describe PaperTrailScrapbook::JournalEntry do
  let(:person) { Person.create!(name: 'The Tim Man') }
  let(:book) { Book.create!(title: 'How the Grinch stole Xmas') }
  let(:version) do
    OpenStruct.new(event: 'create',
                   item_type: 'Book',
                   item_id: book.id,
                   created_at: whenn,
                   version_author: person.id)
  end
  let(:subject) { described_class.new(version) }
  let(:whenn) { Time.parse('2019-12-16 12:01:29 -0800') }

  describe '#story' do
    it 'story' do
      result = subject.story

      expect(result).to eql('On Monday, 16 Dec 2019 at 12:01 PM, '\
                            "created Book[#{book.id}]:\n")
    end
  end
end
