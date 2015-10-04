require 'csv'

require 'honey_format/clean'
require 'honey_format/rows'
require 'honey_format/columns'

module HoneyFormat
  class CSVError < StandardError; end
  class MissingCSVHeaderError       < CSVError; end
  class MissingCSVHeaderColumnError < CSVError; end
  class InvalidCSVHeaderColumnError < CSVError; end
  class InvalidCSVRowLengthError    < CSVError; end

  class CSV
    attr_reader :header, :columns

    def initialize(csv, delimiter: ',', header: nil, valid_columns: :all)
      csv = ::CSV.parse(csv, col_sep: delimiter)
      @csv_body = csv
      @columns = Columns.new(header || csv.shift, valid_columns)
    end

    def header
      @columns.header
    end

    def columns
      @columns.to_a
    end

    def rows
      @rows ||= Rows.new(@csv_body, @columns.to_a).to_a
    end

    def row_count
      rows.length
    end

    private

    def build_header(header)
      header || fail(MissingCSVHeaderError, "CSV header can't be empty.")
      Clean.row(header)
    end
  end
end
