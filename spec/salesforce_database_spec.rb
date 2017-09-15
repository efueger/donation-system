# frozen_string_literal: true

require 'salesforce_database'
require 'spec_helper'

SalesforceData = Struct.new(:amount, :email, :name)

RSpec.describe SalesforceDatabase do
  describe 'supporter exists', vcr: { record: :all } do
    let(:client) { Restforce.new(host: 'cs70.salesforce.com') }
    let(:database) { SalesforceDatabase.new(client) }

    it 'finds an existing supporter by email' do
      found = database.search_supporter_by(:Email, 'test@test.com')
      expect(found[:Email]).to eq('test@test.com')
    end

    it 'picks oldest supporter if several exist with same email' do
      found = database.search_supporter_by(:Email, 'repeated_email@test.com')
      expect(found[:First_entered__c]).to eq('2017-08-01')
    end

    it 'adds donation to the database' do
      data = SalesforceData.new('20', 'test@test.com')
      expect(database.add_donation(data)).to eq([])
    end
  end

  describe 'supporter does not exist', vcr: { record: :all } do
    let(:client) { Restforce.new(host: 'cs70.salesforce.com') }
    let(:database) { SalesforceDatabase.new(client) }

    it 'returns nothing if there is no supporter with that email' do
      found = database.search_supporter_by(:Email, 'i-dont-exist@test.com')
      expect(found).to be_nil
    end

    it 'knows how to create a supporter with the right fields' do
      data = SalesforceData.new('irrelevant', 'a-supporter@test.com', 'A Name')
      supporter = database.create_supporter(data)
      expect(supporter[:LastName]).to eq('A Name')
      expect(supporter[:Email]).to eq('a-supporter@test.com')
    end
  end
end
