# frozen_string_literal: true

RSpec.describe PaperTrailScrapbook do
  describe '.config' do
    it 'sets the @config ivar' do
      described_class.config

      expect(described_class.instance_variable_get(:@config))
        .to equal(PaperTrailScrapbook::Config.instance)
    end
  end
end
