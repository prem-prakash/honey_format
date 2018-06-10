require 'spec_helper'

describe HoneyFormat::CSV do
  let(:csv_string) {
<<-CSV
email, ids
test@example.com,42
CSV
  }

let(:diabolical_csv) {
<<-CSV
"Email Address","First Name","Last Name",MEMBER_RATING,OPTIN_TIME,OPTIN_IP,CONFIRM_TIME,CONFIRM_IP,LATITUDE,LONGITUDE,GMTOFF,DSTOFF,TIMEZONE,CC,REGION,LAST_CHANGED,LEID,EUID,NOTES
mail@example.com,,,2,,,"2015-03-16 14:40:47",,,,,,,,,"2015-03-16 14:40:47",some-value,some-other-value,
CSV
}

let(:diabolical_cols) {
  [:email_address,
   :first_name,
   :last_name,
   :member_rating,
   :optin_time,
   :optin_ip,
   :confirm_time,
   :confirm_ip,
   :latitude,
   :longitude,
   :gmtoff,
   :dstoff,
   :timezone,
   :cc,
   :region,
   :last_changed,
   :leid,
   :euid,
   :notes]
}

  describe 'missing header' do
    it 'should fail' do
      expect { described_class.new('') }.to raise_error(HoneyFormat::MissingHeaderError)
    end
  end

  describe 'with specified header' do
    it 'returns correct csv object' do
      csv_string = "1,buren"
      csv = described_class.new(csv_string, header: ['Id', 'Username'])
      expect(csv.rows.first.username).to eq('buren')
    end
  end

  describe '#each_row' do
    it 'yields each row' do
      csv = described_class.new("email, ids\ntest@example.com,42")
      csv.each_row do |row|
        expect(row.email).to eq('test@example.com')
        expect(row.ids).to eq('42')
      end
    end
  end

  describe '#header' do
    it 'returns an instance of Header' do
      csv = " ID ,Name"
      result = described_class.new(csv).header
      expect(result).to be_a(HoneyFormat::Header)
    end
  end

  describe '#columns' do
    it 'returns a CSVs header' do
      result = described_class.new(csv_string).columns
      expect(result).to eq(%i(email ids))
    end

    it 'can validate and return when all headers are valid in valid_columns' do
      result = described_class.new(csv_string, valid_columns: [:email, :ids]).columns
      expect(result).to eq(%i(email ids))
    end
  end

  describe '#columns' do
    it 'returns correct columns for a diabolical CSV' do
      result = described_class.new(diabolical_csv).columns
      expect(result).to eq(diabolical_cols)
    end
  end

  describe '#rows' do
    it 'returns CSV rows' do
      csv = described_class.new(csv_string).rows
      expect(csv.first.email).to eq('test@example.com')
      expect(csv.first.ids).to eq('42')
    end

    it 'returns CSV rows and ignores empty lines' do
      csv = described_class.new("#{csv_string}\n\n\ntest1@example.com,73").rows
      expect(csv.first.email).to eq('test@example.com')
      expect(csv.first.ids).to eq('42')
      expect(csv.to_a.last.email).to eq('test1@example.com')
      expect(csv.to_a.last.ids).to eq('73')
    end

    it 'works for a diabolical example' do
      result = described_class.new(diabolical_csv).rows.first
      expect(result.confirm_time).to eq('2015-03-16 14:40:47')
      expect(result.leid).to eq('some-value')
      expect(result.euid).to eq('some-other-value')
    end
  end

  it 'can handle alternative delimiters' do
    csv = <<-CSV
    email; ids
    test@example.com; 42
    CSV
    result = described_class.new(csv, delimiter: ';').columns
    expect(result).to eq(%i(email ids))
  end

  describe '#to_csv' do
    it 'returns a CSV-string' do
      csv_string = "1,buren"
      csv = described_class.new(csv_string, header: ['Id', 'Username'])
      expect(csv.to_csv).to eq("id,username\n1,buren\n")
    end

    it 'returns a CSV-string with selected columns' do
      csv_string = "1,buren"
      csv = described_class.new(csv_string, header: ['Id', 'Username'])
      expect(csv.to_csv(columns: [:username])).to eq("username\nburen\n")
    end

    it 'returns a CSV-string with selected rows' do
      csv_string = "1,buren\n2,jacob"
      csv = described_class.new(csv_string, header: ['Id', 'Username'])
      expect(csv.to_csv { |row| row.username == 'buren' }).to eq("id,username\n1,buren\n")
    end

    it 'returns a valid CSV-string even if values needs special quoting' do
      csv_string = '1,"jacob ""buren"" burenstam"'
      csv = described_class.new(csv_string, header: ['Id', 'Username'])
      expected = <<~CSV
      id,username\n1,"jacob ""buren"" burenstam"
      CSV
      expect(csv.to_csv).to eq(expected)
    end

    it 'returns correct for diabolical CSV-string that have caused problems in the passed' do
      csv_string = '333333-1,2015-05-24 23:31:16,None,visa,1111111111,1119.00,0000-00-00 00:00:00,IE,"John ""JD"" Doe ",,51 Some Court,Someville,Dublin 33,,"Sometown,",IE,"John ""JD"" Doe ",,51 Some Court,Someville,Dublin 33,,"Sometown,",john@example.com,1,1119.00,0.00,0.00,1119.00,0.00,23.80,1119.00,0,EUR,9.24140,1099.73,219.95,0.00,0.00,,,,'
      header = 'order,order_date,paytype,payment_method_code,payment_reference,captured,captured_date,billing_country,billing_name,billing_company,billing_address,billing_coaddress,billing_zipcode,billing_state,billing_city,delivery_country,delivery_name,delivery_company,delivery_address,delivery_coaddress,delivery_zipcode,delivery_state,delivery_city,delivery_email,pcs,product_order_value(ex_vat),shipping_value(ex_vat),voucher_value(ex_vat),total_order_value(ex_vat),vat_deduct,vat,total_order_value(inc_vat),refunded,currency,currency_rate,total_order_value(sek),vat(sek),shipping_value(ex_vat)(sek),voucher_value(ex_vat)(sek),affiliate,ec_vat,vat#,collection'.split(',')

      csv = described_class.new(csv_string, header: header)
      expected = <<~CSV
      order,order_date,paytype,payment_method_code,payment_reference,captured,captured_date,billing_country,billing_name,billing_company,billing_address,billing_coaddress,billing_zipcode,billing_state,billing_city,delivery_country,delivery_name,delivery_company,delivery_address,delivery_coaddress,delivery_zipcode,delivery_state,delivery_city,delivery_email,pcs,product_order_value(ex_vat),shipping_value(ex_vat),voucher_value(ex_vat),total_order_value(ex_vat),vat_deduct,vat,total_order_value(inc_vat),refunded,currency,currency_rate,total_order_value(sek),vat(sek),shipping_value(ex_vat)(sek),voucher_value(ex_vat)(sek),affiliate,ec_vat,vat#,collection
      333333-1,2015-05-24 23:31:16,None,visa,1111111111,1119.00,0000-00-00 00:00:00,IE,"John ""JD"" Doe ",,51 Some Court,Someville,Dublin 33,,"Sometown,",IE,"John ""JD"" Doe ",,51 Some Court,Someville,Dublin 33,,"Sometown,",john@example.com,1,1119.00,0.00,0.00,1119.00,0.00,23.80,1119.00,0,EUR,9.24140,1099.73,219.95,0.00,0.00,,,,
      CSV
      csv_output = csv.to_csv
      expect(csv_output).to eq(expected)
      expect(CSV.parse(csv_output)).to be_a(Array)
    end

    it 'returns a CSV-string with values changed by custom row builder' do
      csv_string = "1,buren"
      upcase_builder = Class.new do
        def self.call(row)
          row.username = row.username.upcase
          row
        end
      end

      csv = described_class.new(
        csv_string,
        header: ['Id', 'Username'],
        row_builder: upcase_builder
      )
      expect(csv.to_csv).to eq("id,username\n1,BUREN\n")
    end
  end
end
