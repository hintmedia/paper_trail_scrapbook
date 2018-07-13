# frozen_string_literal: true

require 'spec_helper'

module PaperTrailScrapbook
  RSpec.describe UserJournal do
    before do
      PaperTrailScrapbook.config.whodunnit_class = Person
      PaperTrail.request.whodunnit               = person.id

      a_ship
    end

    let(:name) { 'The Tim Man' }
    let(:title) { 'How the Grinch stole Xmas' }
    let(:a_name) { 'Dr. Seuss' }
    let(:changes) { 'made the following changes:' }
    let(:b_changes) { 'made the following Book changes:' }

    let(:book) { Book.create!(title: title) }
    let(:author) { Person.create!(name: a_name) }
    let(:a_ship) { Authorship.create!(book: book, author: author) }
    let(:person) do
      who                          = PaperTrail.request.whodunnit
      PaperTrail.request.whodunnit = nil
      p                            = Person.new(name: name)
      p.save!
      PaperTrail.request.whodunnit = who
      p
    end
    let(:format) { PaperTrailScrapbook.config.time_format }
    let(:object) { described_class.new(person) }
    let(:subject) { object.story }
    let(:f_starts) { starts.strftime(format).squeeze(' ') }
    let(:f_ends) { ends.strftime(format).squeeze(' ') }

    describe '#story' do
      context 'with a provided user' do
        it 'provides a whole story' do
          # expect(object.starts).to eql 'Thursday, 01 Jan 1970 at 12:00 AM'
          # expect(object.ends).to eql Time.current.in_time_zone

          expect(subject)
            .to match(/Between .* and .*, #{name} #{changes}/)
          expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title}/)
          expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
          expect(subject).to match(/ • name: #{a_name}/)
          expect(subject).to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
          expect(subject).to match(/ • book: #{title}\[#{book.id}\]/)
          expect(subject).to match(/ • author: Dr. Seuss\[#{author.id}\]/)
        end

        it 'provides a whole story missing to_s content' do
          book.title = nil
          book.save!

          expect(subject).to match(/On .*, updated Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title} was \*removed\*/)
        end
      end

      context 'with missing references' do
        it 'provides a whole story missing reference' do
          book.destroy

          expect(subject).to match(/book: \*not found\*\[/)
        end

        it 'provides a whole story missing reference' do
          a_ship.book = nil
          a_ship.save!

          expect(subject).to match(/#{title}\[\d+\] was \*removed\*/)
        end
      end

      context 'with a provided class' do
        let(:object) { described_class.new(person, klass: Book) }

        it 'provides a story for provided class' do
          expect(subject)
            .to match(/Between .* and .*, #{name} #{b_changes}/)
          expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title}/)
          expect(subject).not_to match(/On .*, created Person\[#{author.id}\]:/)
          expect(subject).not_to match(/ • name: #{a_name}/)
          expect(subject)
            .not_to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
        end
      end

      context 'with start time and class but no end time' do
        let(:object) { described_class.new(person, klass: Book, start: starts) }
        let(:starts) { Time.current.advance(minutes: -5) }

        it 'provides a story with start time' do
          expect(subject)
            .to match(/Between #{f_starts} and .*, #{name} #{b_changes}/)
          expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title}/)
          expect(subject).not_to match(/On .*, created Person\[#{author.id}\]:/)
          expect(subject).not_to match(/ • name: #{a_name}/)
          expect(subject)
            .not_to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
        end
      end

      context 'with end time but no start time and no class' do
        let(:ends) { Time.current.advance(minutes: 5) }
        let(:object) { described_class.new(person, end: ends) }

        it 'provides a story with end time in the future' do
          expect(subject)
            .to match(/Between .* and #{f_ends}, #{name} #{changes}/)
          expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title}/)
          expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
          expect(subject).to match(/ • name: #{a_name}/)
          expect(subject).to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
        end

        describe 'with end time in past' do
          let(:ends) { Time.current.advance(minutes: -5) }

          it 'provides a story with end time in the past' do
            expect(subject).not_to match(/#{name} created the following Person/)
            expect(subject).not_to match(/#{name} created the following Book/)
            expect(subject).not_to match(/#{title}/)
            expect(subject).not_to match(/#{name} created the following Author/)
          end
        end
      end

      context 'with start and end times but no class' do
        let(:starts) { Time.current.advance(minutes: -4) }
        let(:ends) { starts.advance(hours: 1) }
        let(:object) { described_class.new(person, start: starts, end: ends) }

        it 'provides a story with start and end times' do
          expect(subject)
            .to match(/Between .* and .*, #{name} #{changes}/)
          expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
          expect(subject).to match(/ • title: #{title}/)
          expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
          expect(subject).to match(/ • name: #{a_name}/)
          expect(subject).to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
          expect(subject).to match(/ • book: #{title}\[#{book.id}\]/)
        end
      end

      context 'with start time, end time, and a class' do
        let(:starts) { Time.current.advance(minutes: -4) }
        let(:ends) { starts.advance(hours: 1) }
        let(:object) do
          described_class.new(person, klass: Book, start: starts, end: ends)
        end

        describe 'when time range covers current time' do
          it 'provides a story for provided class with start and end times' do
            expect(subject)
              .to match(/Between #{f_starts} and #{f_ends}, #{name} #{b_changes}/)
            expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
            expect(subject).to match(/ • title: #{title}/)
            expect(subject)
              .not_to match(/On .*, created Person\[#{author.id}\]:/)
            expect(subject).not_to match(/ • name: #{a_name}/)
            expect(subject)
              .not_to match(/On .*, created Authorship\[#{a_ship.id}\]:/)
          end
        end

        describe 'when time range is completely in the future' do
          let(:starts) { Time.current.advance(minutes: 4) }

          it 'provides a story' do
            expect(subject).to eql("Between #{f_starts} and #{f_ends}, #{name}"\
                                     " #{b_changes}\n\nNo history".squeeze(' '))
          end
        end

        describe 'when no time range' do
          let(:starts) { nil }
          let(:ends) { nil }
          it 'provides a story' do
            expect(subject)
              .to match('Between Thursday, 01 Jan 1970 at 12:00 AM ' \
                          "and #{Time.current.in_time_zone.strftime(format).squeeze(' ')}, #{name}"\
                                     " #{b_changes}\n\n".squeeze(' '))
          end
        end
      end
    end
  end
end
