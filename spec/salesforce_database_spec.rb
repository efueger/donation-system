# frozen_string_literal: true

require 'salesforce_database'
require 'spec_helper'

SalesforceData = Struct.new(:amount, :email, :name)

RSpec.describe SalesforceDatabase do
  describe 'supporter exists', vcr: { record: :once } do
    let(:client) { Restforce.new(host: 'cs70.salesforce.com') }
    let(:database) { SalesforceDatabase.new(client) }

    it 'finds an existing supporter by email' do
      data = SalesforceData.new('irrelevant', 'test@test.com')
      found = database.search_supporter_by_email(data.email)
      expect(found[:Email]).to eq('test@test.com')
    end

    it 'picks oldest supporter if several exist with same email' do
      data = SalesforceData.new('irrelevant', 'repeated_email@test.com')
      found = database.search_supporter_by_email(data.email)
      expect(found[:First_entered__c]).to eq('2017-08-01')
    end

    it 'adds donation to the database' do
      data = SalesforceData.new('20', 'test@test.com')
      expect(database.add_donation(data)).to eq([])
    end

    it 'attaches the donation to a supporter' do
      client_mock = instance_double(Restforce::Concerns::API).as_null_object
      allow(client_mock).to receive(:query).and_return(supporter_data)
      database_with_mock = SalesforceDatabase.new(client_mock)
      data = SalesforceData.new('20', 'test@test.com')

      database_with_mock.add_donation(data)

      expect(client_mock).to have_received(:create!).with(
        'Opportunity',
        Amount: '20',
        CloseDate: '2017-09-11',
        Name: 'Online donation',
        StageName: 'Received',
        AccountId: '0013D00000LBYutQAH'
      )
    end

    def supporter_data
      [
        {
          'attributes' => {
            'type' => 'Contact',
            'url' => '/services/data/v38.0/sobjects/Contact/0033D00000KoEluQAF'
          },
          'Email' => 'test@test.com', 'First_entered__c' => '2017-09-11',
          'AccountId' => '0013D00000LBYutQAH'
        }
      ]
    end
  end

  describe 'supporter does not exist', vcr: { record: :once } do
    let(:client) { Restforce.new(host: 'cs70.salesforce.com') }
    let(:database) { SalesforceDatabase.new(client) }

    it 'knows how to create a supporter with the right fields' do
      data = SalesforceData.new('irrelevant', 'a-supporter@test.com', 'A Name')
      supporter = database.create_supporter(data)
      expect(supporter[:LastName]).to eq('A Name')
    end

    it 'creates a supporter if it can not be found by email' do
      data = SalesforceData.new('20', 'a-supporter@test.com', 'A Name')
      expect(database.add_donation(data)).to eq([])
    end

    it 'creates the supporter with an email' do
      client_mock = instance_double(Restforce::Concerns::API).as_null_object
      allow(client_mock).to receive(:create!).and_return('1')
      allow(client_mock).to receive(:query).and_return([])
      database_with_mock = SalesforceDatabase.new(client_mock)
      data = SalesforceData.new('irrelevant', 'a-supporter@test.com', 'A Name')

      database_with_mock.create_supporter(data)

      expect(client_mock).to have_received(:create!).with(
        'Contact',
        LastName: 'A Name',
        Email: 'a-supporter@test.com'
      )
    end
  end
end
