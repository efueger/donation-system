# frozen_string_literal: true

require 'restforce'
require 'salesforce/donation_data'
require 'salesforce/supporter_data'

class SalesforceDatabase
  def initialize(client = Restforce.new)
    @client = client
  end

  def add_donation(data)
    supporter = ensure_supporter(data)
    donation_id = create_donation(data, supporter)
    [] if donation_id
  end

  def search_supporter_by(field, value)
    supporters = search(search_supporter_by_query(field, value))
    first_entered = select_first_entered_supporter(supporters)
    return unless first_entered
    find(Salesforce::SupporterData::TABLE_NAME, first_entered['Id'])
  end

  def create_supporter(data)
    sobject_name = Salesforce::SupporterData::TABLE_NAME
    sobject_fields = Salesforce::SupporterData.new(data).fields
    supporter_id = create(sobject_name, sobject_fields)
    find(Salesforce::SupporterData::TABLE_NAME, supporter_id)
  end

  def create_donation(data, supporter)
    sobject_name = Salesforce::DonationData::TABLE_NAME
    sobject_fields = Salesforce::DonationData.new(data, supporter).fields
    create(sobject_name, sobject_fields)
  end

  private

  attr_reader :client

  def search(query)
    client.query(query)
  end

  def create(sobject_name, sobject_fields)
    client.create!(sobject_name, sobject_fields)
  end

  def find(sobject_name, id)
    client.find(sobject_name, id)
  end

  def ensure_supporter(data)
    search_supporter_by(:Email, data.email) || create_supporter(data)
  end

  def select_first_entered_supporter(supporters)
    supporters.sort_by { |contact| contact[:First_entered__c] }.first
  end

  def search_supporter_by_query(field, value)
    %(
      select Id, First_entered__c
      from #{Salesforce::SupporterData::TABLE_NAME}
      where #{field}='#{value}'
    ).gsub(/\s+/, ' ').strip
  end
end
