# frozen_string_literal: true

require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe Versions do
    before do
      PaperTrailScrapbook.config.whodunnit_class = Person
      PaperTrail.request.whodunnit = person.id
    end

    let(:book) do
      Book.new(title: 'How the Grinch stole Xmas').tap(&:save!)
    end
    let(:person) { Person.create(name: 'The Tim Man') }
    let!(:authorship) do
      Authorship.new(book: book, author: person).tap(&:save!)
    end

    let(:object) { described_class.new(book) }

    describe '#versions' do
      it 'versions' do
        book.update!(title: 'New Title')

        result = object.versions

        expect(result).to eql(book.versions.to_a)
        expect(result.size).to equal(2)
      end
    end

    describe '#related_content' do
      it 'related_content returns nothing if no related content' do
        result = object.related_content

        expect(result).to eql([])
      end

      it 'returns related content' do
        allow(book).to receive(:respond_to?)
          .with(:trailed_related_content).and_return(true)
        allow(book).to receive(:respond_to?)
          .with(:trailed_related_content, true).and_return(true)
        allow(book).to receive(:trailed_related_content) do
          book.authorships
        end

        result = object.related_content

        expect(result).to eql(authorship.versions.to_a)
      end
    end

    describe '#filtered' do
      it 'returns versions if no filter' do
        result = object.filtered(book.versions.to_a)

        expect(result).to eql(book.versions.to_a)
      end

      it 'returns filtered versions if filter' do
        allow(book).to receive(:respond_to?)
          .with(:version_filter, true).and_return(true)
        allow(book).to receive(:respond_to?)
          .with(:version_filter).and_return(true)
        allow(book).to receive(:version_filter) do |_version|
          nil
        end

        result = object.filtered(book.versions.to_a)

        expect(result).to eql([])
      end

      it 'returns filtered versions if filter' do
        book.update!(title: 'New Title')

        allow(book).to receive(:respond_to?).with(:version_filter, true).and_return(true)
        allow(book).to receive(:respond_to?).with(:version_filter).and_return(true)
        allow(book).to receive(:version_filter) do |version|
          version if version.event.eql?('update')
        end

        result = object.filtered(book.versions)

        expect(result).to eql([book.versions.last])
        expect(result.size).not_to eql(book.versions.size)
      end
    end
  end
end
