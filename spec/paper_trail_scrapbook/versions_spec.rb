# frozen_string_literal: true

require 'spec_helper'
require 'paper_trail_scrapbook/versions'

module PaperTrailScrapbook
  ::RSpec.describe Versions do

    before do
      PaperTrailScrapbook.config.whodunnit_class = Person
      PaperTrail.request.whodunnit = person.id
    end

    let(:person) { Person.create(name: 'The Tim Man') }

    let(:book) do
      b = Book.new(title: 'How the Grinch stole Xmas')
      b.save!
      b
    end

    let(:author) do
      p = Person.new(name: 'Dr. Seuss')
      p.save!
      p
    end

    let(:authorship) do
      a = Authorship.new(book: book, author: author)
      a.save!
      a
    end

    let(:object) { described_class.new(authorship) }

    # TODO: auto-generated
    describe '#versions' do
      it 'versions' do
        result = object.versions

        expect(result).not_to be_nil
      end
    end

    # TODO: auto-generated
    describe '#related_content' do
      it 'related_content' do
        result = object.related_content

        expect(result).not_to be_nil
      end
    end

    # TODO: auto-generated
    describe '#filtered' do
      it 'filtered' do
        result = object.filtered(authorship.versions)

        expect(result).not_to be_nil
      end
    end

  end

end
