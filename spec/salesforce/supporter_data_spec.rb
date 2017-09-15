# frozen_string_literal: true

require 'salesforce/supporter_data'
require 'spec_helper'

RawSupporterData = Struct.new(:name, :email)

module Salesforce
  RSpec.describe SupporterData do
    let(:data) { RawSupporterData.new('A Name', 'test@test.com') }
    let(:supporter_data) { described_class.new(data) }

    it 'knows its table name' do
      expect(described_class::TABLE_NAME).to eq('Contact')
    end

    describe 'Salesforce required fields' do
      it 'requires a last name' do
        expect(supporter_data.fields[:LastName]).to eq('A Name')
      end
    end

    describe 'application required fields' do
      it 'requires an email' do
        expect(supporter_data.fields[:Email]).to eq('test@test.com')
      end
    end

    describe 'validations' do
      it 'handles missing last name' do
        data = RawSupporterData.new(nil, 'test@test.com')
        supporter_data = described_class.new(data)
        expect(supporter_data.fields).to be_nil
        expect(supporter_data.errors).to include(:invalid_last_name)
      end

      it 'handles missing email' do
        data = RawSupporterData.new('A Name', nil)
        supporter_data = described_class.new(data)
        expect(supporter_data.fields).to be_nil
        expect(supporter_data.errors).to include(:invalid_email)
      end

      it 'has no validation errors if data is valid' do
        expect(supporter_data.fields).not_to be_nil
        expect(supporter_data.errors).to eq([])
      end
    end
  end
end
