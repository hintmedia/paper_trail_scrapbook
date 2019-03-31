# frozen_string_literal: true

require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe LifeHistory do
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

    let(:target) do
      a = Authorship.new(book: book, author: author)
      a.save!
      a
    end

    let(:object) { described_class.new(target) }
    let(:subject) { object.story }

    describe '#story' do
      it 'provides a whole story' do
        expect(subject).to match(/The Tim Man/)

        expect(subject).to match(/How the Grinch stole Xmas\[/)
        expect(subject).to match(/Dr. Seuss\[/)
      end

      it 'provides a whole story missing to_s content' do
        book.title = nil
        book.save!

        expect(subject).to match(/book: \[/)
      end

      it 'provides a whole story missing reference' do
        book.destroy

        expect(subject).to match(/book: \*not found\*\[/)
      end

      it 'provides a whole story missing reference' do
        target.book = nil
        target.save!

        expect(subject)
          .to match(/How the Grinch stole Xmas\[\d+\] was \*removed\*/)
      end

      context 'it handles missing whodunnit record' do
        it 'provides a whole story with missing whodunnit record' do
          target
          pid = person.id
          person.destroy

          expect(subject)
            .to match(/\*missing \(#{pid}\)\* created the following/)
        end
      end

      context 'with overridden invalid whodunnit handler' do
        it 'allows for a custom invalid_whodunnit handler' do
          config = PaperTrailScrapbook.config
          handler = config.invalid_whodunnit
          config.invalid_whodunnit = proc { |w| "*WHO (#{w})*" }

          target
          pid = person.id
          person.destroy

          expect(subject).to match(/\*WHO \(#{pid}\)\* created the following/)

          config.invalid_whodunnit = handler
        end
      end

      context 'no papertrail' do
        let(:target) { Elephant.create! }

        it 'has none' do
          target
          expect(subject).to eql ''
        end
      end

      context 'with related data' do
        before do
          author
          book
          target

          def target.trailed_related_content
            [book, author]
          end
        end

        it 'includes related content history' do
          expect(subject).to match(/created the following Person\[\d+\] info/)
          expect(subject).to match(/name: Dr\. Seuss/)

          expect(subject).to match(/created the following Book\[\d+\] info/)
          expect(subject).to match(/title: How the Grinch stole Xmas/)

          expect(subject).to match(/created the following Authorship info/)
          expect(subject).to match(/book: How the Grinch stole Xmas\[\d+\]/)
          expect(subject).to match(/author: Dr\. Seuss\[\d+\]/)
        end
      end

      context 'recent first' do
        before do
          author
          book
          target

          config = PaperTrailScrapbook.config
          config.recent_first = true
          config.time_format = '%A, %d %b %Y at %l:%M:%S.%9N %p'

          def target.trailed_related_content
            [book, author]
          end
        end

        it 'includes related content history' do
          expect(subject).to match(/created the following Person\[\d+\] info/)
          expect(subject).to match(/name: Dr\. Seuss/)

          expect(subject).to match(/created the following Book\[\d+\] info/)
          expect(subject).to match(/title: How the Grinch stole Xmas/)

          expect(subject).to match(/created the following Authorship info/)
          expect(subject).to match(/book: How the Grinch stole Xmas\[\d+\]/)
          expect(subject).to match(/author: Dr\. Seuss\[\d+\]/)
        end
      end
    end
  end
end
