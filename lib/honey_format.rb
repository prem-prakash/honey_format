# frozen_string_literal: true

require 'honey_format/version'
require 'honey_format/configuration'
require 'honey_format/errors'
require 'honey_format/registry'
require 'honey_format/converters/converters'
require 'honey_format/csv'

# Main module for HoneyFormat
module HoneyFormat
  # CSV alias
  HoneyCSV = CSV

  # Configure HoneyFormat
  # @yield [configuration] the configuration
  # @yieldparam [Configuration] current configuration
  # @return [Configuration] current configuration
  def self.configure
    @configuration ||= Configuration.new
    yield(@configuration) if block_given?
    @configuration
  end

  # Returns the current configuration
  # @return [Configuration] current configuration
  def self.config
    configure
  end

  # Returns the configured header converter
  # @return [#call] the current header converter
  def self.header_converter
    config.header_converter
  end

  # Returns the configured converter registry
  # @return [Registry] the current converter registry
  def self.converter_registry
    config.converter_registry
  end

  # Returns the configured deduplicator registry
  # @return [Registry] the current deduplicator registry
  def self.header_deduplicator_registry
    config.header_deduplicator_registry
  end
end
