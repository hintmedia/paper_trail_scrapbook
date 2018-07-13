require 'spec_helper'
require 'ostruct'

module PaperTrailScrapbook
  RSpec.describe VersionHelpers do
    let(:person) { Person.create!(name: 'The Tim Man') }
    let(:book) { Book.create!(title: 'How the Grinch stole Xmas') }
    let(:version) do
      OpenStruct.new(event: 'create',
                     item_type: 'Book',
                     item_id: book.id,
                     created_at: Time.current,
                     version_author: person.id)
    end
    let(:config) { PaperTrailScrapbook.config }
    let(:subject) { JournalEntry.new(version) }

    before do
      PaperTrailScrapbook.config.whodunnit_class = Person
      PaperTrail.request.whodunnit = person.id
    end

    describe '#model' do
      it 'returns expected result' do
        expect(subject.model).to eql('Book')
      end
    end

    describe '#model_id' do
      it 'returns expected result' do
        expect(subject.model_id).to equal(book.id)
      end
    end

    describe '#create?' do
      it 'returns true if create event' do
        expect(subject.create?).to be true
      end

      it 'returns false if not create event' do
        version.event = 'update'

        expect(subject.create?).to be false
      end
    end

    describe '#changes' do
      it 'returns changes' do
        expect(subject.changes).to eql('')
      end
    end

    describe '#config' do
      it 'returns instance of Config' do
        expect(subject.config).to be_an_instance_of(PaperTrailScrapbook::Config)
      end
    end

    describe '#whenn' do
      it 'returns version created_at' do
        expect(subject.whenn)
          .to eql(version.created_at.strftime(config.time_format))
      end
    end

    describe '#kind' do
      it 'returns expected value' do
        expect(subject.kind).to eql('created')
      end

      context 'garbage' do
        let(:subject) { JournalEntry.new(version) }
        it 'returns expected value' do
          x = PaperTrailScrapbook.config.events
          PaperTrailScrapbook.config.events = {}

          expect { subject.kind }.to raise_error(ArgumentError, 'incorrect event:create')

          PaperTrailScrapbook.config.events = x
        end
      end
    end

    describe '#who' do
      it 'returns expected value' do
        expect(subject.who).to eql(person.name)
      end
    end

    describe '#whodunnit_class' do
      it 'returns expected value' do
        expect(subject.whodunnit_class).to eql(Person)
      end
    end
  end
end
