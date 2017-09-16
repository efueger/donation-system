# frozen_string_literal: true

require 'salesforce/donation_data'

module Salesforce
  class Donation
    def initialize(client)
      @client = client
    end

    def create(data, supporter)
      sobject_name = DonationData::TABLE_NAME
      sobject_fields = DonationData.new(data, supporter).fields
      create!(sobject_name, sobject_fields)
    end

    private

    attr_reader :client

    def create!(sobject_name, sobject_fields)
      client.create!(sobject_name, sobject_fields)
    end
  end
end
