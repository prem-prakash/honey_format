require 'spec_helper'

RSpec.describe HoneyFormat::Configuration do
  describe '#header_converter=' do
    it 'can set header converter from Symbol' do
      expected = HoneyFormat.value_converter[:upcase]

      config = described_class.new
      config.header_converter = :upcase

      expect(config.header_converter).to eq(expected)
    end

    it 'can set header converter' do
      expected = HoneyFormat.value_converter[:upcase]

      config = described_class.new
      config.header_converter = expected

      expect(config.header_converter).to eq(expected)
    end
  end

  describe '#converter' do
    it 'returns a value converter' do
      expect(described_class.new.converter).to be_a(HoneyFormat::ValueConverter)
    end
  end
end