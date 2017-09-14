# frozen_string_literal: true

require 'salesforce/donation_data'
require 'spec_helper'

RawData = Struct.new(:amount, :account_id)

module Salesforce
  RSpec.describe DonationData do
    let(:data) { RawData.new('20', '1') }
    let(:donation_data) { described_class.new(data) }

    it 'knows its table name' do
      expect(described_class::TABLE_NAME).to eq('Opportunity')
    end

    describe 'Salesforce required fields' do
      it 'requires an amount' do
        expect(donation_data.fields[:Amount]).to eq('20')
      end

      it 'requires a closed date' do
        expect(donation_data.fields[:CloseDate]).to eq('2017-09-11')
      end

      it 'requires a name' do
        expect(donation_data.fields[:Name]).to eq('Online donation')
      end

      it 'requires a stage name' do
        expect(donation_data.fields[:StageName]).to eq('Received')
      end
    end

    describe 'application required fields' do
      it 'requires an account id' do
        expect(donation_data.fields[:AccountId]).to eq('1')
      end
    end

    describe 'validations' do
      it 'handles missing amount' do
        data = RawData.new(nil, '1')
        donation_data = described_class.new(data)
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_amount)
      end

      it 'handles invalid amount' do
        data = RawData.new('asdf', '1')
        donation_data = described_class.new(data)
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_amount)
      end

      it 'handles invalid account id' do
        data = RawData.new('20', nil)
        donation_data = described_class.new(data)
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_account_id)
      end

      it 'has no validation errors if data is valid' do
        expect(donation_data.fields).not_to be_nil
        expect(donation_data.errors).to eq([])
      end
    end
  end
end
