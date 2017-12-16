require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe UserJournal do
    let(:person) do
      who = PaperTrail.whodunnit
      PaperTrail.whodunnit = nil
      p = Person.new(name: 'The Tim Man')
      p.save!
      PaperTrail.whodunnit = who
      p
    end

    before do
      PaperTrailScrapbook.config.whodunnit_class = Person
      PaperTrail.whodunnit = person.id
    end

    let!(:book) do
      b = Book.new(title: 'How the Grinch stole Xmas')
      b.save!
      b
    end

    let(:book2) do
      b = Book.new(title: 'Green Eggs and Ham')
      b.save!
      b
    end

    let!(:author) do
      p = Person.new(name: 'Dr. Seuss')
      p.save!
      p
    end

    let!(:target) do
      a = Authorship.new(book: book, author: author)
      a.save!
      a
    end

    let(:format) { PaperTrailScrapbook.config.time_format }

    let(:object) { described_class.new(person, {}) }
    let(:subject) { object.story }

    describe '#story' do
      it 'provides a whole story' do
        expect(subject)
          .to match(/Between .* and .*, The Tim Man made the following changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).to match(/ • name: Dr. Seuss/)
        expect(subject).to match(/On .*, created Authorship\[#{target.id}\]:/)
        expect(subject)
          .to match(/ • book: How the Grinch stole Xmas\[#{book.id}\]/)
      end

      it 'provides a whole story missing to_s content' do
        book.title = nil
        book.save!

        expect(subject)
          .to match(/Between .* and .*, The Tim Man made the following changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).to match(/ • name: Dr. Seuss/)
        expect(subject).to match(/On .*, created Authorship\[#{target.id}\]:/)
        expect(subject)
          .to match(/ • book: \[#{book.id}\]/)
        expect(subject).to match(/ • author: Dr. Seuss\[#{author.id}\]/)
        expect(subject).to match(/On .*, updated Book\[#{book.id}\]:/)
        expect(subject)
          .to match(/ • title: How the Grinch stole Xmas was \*removed\*/)
      end

      it 'provides a whole story missing reference' do
        book.destroy

        expect(subject).to match(/book: \*not found\*\[/)
      end

      it 'provides a whole story missing reference' do
        target.book = nil
        target.save!

        expect(subject).to match(/How the Grinch stole Xmas\[1\] was \*removed\*/)
      end

      it 'provides a story for provided class' do
        object  = described_class.new(person, klass: Book)
        subject = object.story

        expect(subject)
          .to match(/Between .* and .*, The Tim Man made the following Book changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).not_to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).not_to match(/ • name: Dr. Seuss/)
        expect(subject).not_to match(/On .*, created Authorship\[#{target.id}\]:/)
      end

      it 'provides a story with start time' do
        starts  = Time.current.advance(minutes: -5)
        object  = described_class.new(person, klass: Book, start: starts)
        subject = object.story

        expect(subject)
          .to match(/Between #{starts.strftime(format).squeeze(' ')} and .*, The Tim Man made the following Book changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).not_to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).not_to match(/ • name: Dr. Seuss/)
        expect(subject).not_to match(/On .*, created Authorship\[#{target.id}\]:/)
      end

      it 'provides a story with end time in the future' do
        ends    = Time.current.advance(minutes: 5)
        object  = described_class.new(person, end: ends)
        subject = object.story

        expect(subject)
          .to match(/Between .* and #{ends.strftime(format).squeeze(' ')}, The Tim Man made the following changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).to match(/ • name: Dr. Seuss/)
        expect(subject).to match(/On .*, created Authorship\[#{target.id}\]:/)
      end

      it 'provides a story with end time in the past' do
        ends    = Time.current.advance(minutes: -5)
        object  = described_class.new(person, end: ends)
        subject = object.story

        expect(subject).not_to match(/The Tim Man created the following Person/)
        expect(subject).not_to match(/The Tim Man created the following Book/)
        expect(subject).not_to match(/How the Grinch stole Xmas/)
        expect(subject).not_to match(/The Tim Man created the following Author/)
      end

      it 'provides a story with start and end times' do
        starts  = Time.current.advance(minutes: -4)
        ends    = starts.advance(hours: 1)
        object  = described_class.new(person,
                                      start: starts,
                                      end:   ends)
        subject = object.story

        expect(subject)
          .to match(/Between .* and .*, The Tim Man made the following changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).to match(/ • name: Dr. Seuss/)
        expect(subject).to match(/On .*, created Authorship\[#{target.id}\]:/)
        expect(subject)
          .to match(/ • book: How the Grinch stole Xmas\[#{book.id}\]/)
      end

      it 'provides a story for provided class with start and end times' do
        starts  = Time.current.advance(minutes: -4)
        ends    = starts.advance(hours: 1)
        object  = described_class.new(person,
                                      klass: Book,
                                      start: starts,
                                      end:   ends)
        subject = object.story

        expect(subject)
          .to match(/Between #{starts.strftime(format).squeeze(' ')} and #{ends.strftime(format).squeeze(' ')}, The Tim Man made the following Book changes:/)
        expect(subject).to match(/On .*, created Book\[#{book.id}\]:/)
        expect(subject).to match(/ • title: How the Grinch stole Xmas/)
        expect(subject).not_to match(/On .*, created Person\[#{author.id}\]:/)
        expect(subject).not_to match(/ • name: Dr. Seuss/)
        expect(subject).not_to match(/On .*, created Authorship\[#{target.id}\]:/)
      end

      it 'provides a story for provided class with future start and end times' do
        starts  = Time.current.advance(minutes: 4)
        ends    = starts.advance(hours: 1)
        object  = described_class.new(person,
                                      klass: Book,
                                      start: starts,
                                      end:   ends)
        subject = object.story

        expect(subject).to eql("Between #{starts.strftime(format)} and "\
                                 "#{ends.strftime(format)}, The Tim Man made "\
                                 "the following Book changes:\n\nNo "\
                                 'history'.squeeze(' '))
      end
    end
  end
end
