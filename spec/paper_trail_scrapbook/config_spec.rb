require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe Config do
    describe '.instance' do
      it 'returns the singleton instance' do
        expect { described_class.instance }.not_to raise_error
        expect(described_class.instance.whodunnit_class).to be_nil
        expect(described_class.instance.time_format)
          .to eql(described_class::DEFAULT_TIME_FORMAT)
        expect(described_class.instance.events)
          .to eql(described_class::DEFAULT_EVENTS)
        expect(described_class.instance.scrub_columns)
          .to eql(described_class::SCRUB_COLUMNS)
        expect(described_class.instance.unknown_whodunnit)
          .to eql(described_class::UNKNOWN_WHODUNNIT)

        expect(described_class.instance.drop_id_suffix)
          .to be true
        expect(described_class.instance.filter_non_changes)
          .to be true
      end
    end

    describe '.new' do
      it 'raises NoMethodError' do
        expect { described_class.new }.to raise_error(NoMethodError)
      end
    end
  end
end
