# frozen_string_literal: true

require 'salesforce/donation_data'
require 'spec_helper'

module Salesforce
  RSpec.describe DonationData do
    let(:donation_data) { setup_field_values(amount: '2000', account_id: '1') }

    it 'knows its table name' do
      expect(described_class::TABLE_NAME).to eq('Opportunity')
    end

    describe 'Salesforce required fields' do
      it 'requires an amount' do
        expect(donation_data.fields[:Amount]).to eq('2000')
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
        donation_data = setup_field_values(amount: nil, account_id: '1')
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_amount)
      end

      it 'handles invalid amount' do
        donation_data = setup_field_values(amount: 'asdf', account_id: '1')
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_amount)
      end

      it 'handles missing supporter' do
        data = RawDonationData.new('2000')
        donation_data = described_class.new(data, nil)
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to eq([:invalid_account_id])
      end

      it 'handles invalid account id' do
        donation_data = setup_field_values(amount: '2000', account_id: nil)
        expect(donation_data.fields).to be_nil
        expect(donation_data.errors).to include(:invalid_account_id)
      end

      it 'has no validation errors if data is valid' do
        expect(donation_data.fields).not_to be_nil
        expect(donation_data.errors).to eq([])
      end
    end

    def setup_field_values(values)
      data = RawDonationData.new(values[:amount])
      supporter = SupporterSObjectFake.new(values[:account_id])
      described_class.new(data, supporter)
    end

    RawDonationData = Struct.new(:amount)
    SupporterSObjectFake = Struct.new(:AccountId)
  end
end
