require 'spec_helper'

describe Spree::StockRecord do
  context 'validation' do
    it { should have_valid_factory(:stock_record) }
  end
end
