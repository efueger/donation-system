# frozen_string_literal: true

require 'restforce'
require 'salesforce/donation_data'

class SalesforceDatabase
  def initialize(client = Restforce.new)
    @client = client
  end

  def add_donation(data)
    supporter = ensure_supporter(data)
    donation_id = create_donation(data, supporter)
    [] if donation_id
  end

  def ensure_supporter(data)
    search_supporter_by_email(data.email) || create_supporter(data)
  end

  def search_supporter_by_email(email)
    supporters = search(search_supporter_by_email_query(email))
    select_first_entered_supporter(supporters)
  end

  def create_supporter(data)
    attributes = salesforce_supporter_required_fields(data)
                 .merge(supporter_required_fields(data))
    supporter_id = create('Contact', attributes)
    search(search_supporter_by_id_query(supporter_id)).first
  end

  RawDonationData = Struct.new(:amount, :account_id)
  def create_donation(data, supporter)
    data = RawDonationData.new(data.amount, supporter['AccountId'])
    sobject_name = Salesforce::DonationData::TABLE_NAME
    sobject_fields = Salesforce::DonationData.new(data).fields
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

  def select_first_entered_supporter(supporters)
    supporters.sort_by { |contact| contact['First_entered__c'] }.first
  end

  def search_supporter_by_email_query(email)
    %(
      select Email, First_entered__c, AccountId, LastName
      from Contact
      where Email='#{email}'
    ).gsub(/\s+/, ' ').strip
  end

  def search_supporter_by_id_query(id)
    %(
      select Email, First_entered__c, AccountId, LastName
      from Contact
      where Id='#{id}'
    ).gsub(/\s+/, ' ').strip
  end

  def salesforce_supporter_required_fields(data)
    { LastName: data.name }
  end

  def supporter_required_fields(data)
    { Email: data.email }
  end
end
