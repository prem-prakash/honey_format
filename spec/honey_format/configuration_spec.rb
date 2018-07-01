# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HoneyFormat::Configuration do
  describe '#header_converter=' do
    it 'can set header converter from Symbol' do
      expected = HoneyFormat.converter[:upcase]

      config = described_class.new
      config.header_converter = :upcase

      expect(config.header_converter).to eq(expected)
    end

    it 'can set header converter' do
      expected = HoneyFormat.converter[:upcase]

      config = described_class.new
      config.header_converter = expected

      expect(config.header_converter).to eq(expected)
    end
  end

  describe '#converter' do
    it 'returns a converter registry' do
      expect(described_class.new.converter).to be_a(HoneyFormat::ConverterRegistry)
    end
  end

  describe '#deduplicate_header_strategy=' do
    it 'can set header converter from Symbol' do
      config = described_class.new
      config.deduplicate_header_strategy = :deduplicate

      expect(config.deduplicate_header_strategy).to be_a(Proc)
    end

    it 'can set header converter' do
      expected = proc { |v| v }

      config = described_class.new
      config.deduplicate_header_strategy = expected

      expect(config.deduplicate_header_strategy).to eq(expected)
    end
  end
end
