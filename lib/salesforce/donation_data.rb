# frozen_string_literal: true

module Salesforce
  class DonationData
    TABLE_NAME = 'Opportunity'

    def initialize(data, supporter)
      @data = data
      @supporter = supporter
    end

    def fields
      return unless valid_data?
      {
        Amount: data.amount.to_s,
        CloseDate: '2017-09-11',
        Name: 'Online donation',
        StageName: 'Received',
        AccountId: supporter[:AccountId]
      }
    end

    def errors
      validation_errors = []
      validation_errors << validate_amount
      validation_errors << validate_account_id
      validation_errors.compact
    end

    private

    attr_reader :data, :supporter

    def valid_data?
      errors.empty?
    end

    def validate_amount
      :invalid_amount unless data.amount && !data.amount.to_i.zero?
    end

    def validate_account_id
      :invalid_account_id unless supporter && supporter[:AccountId]
    end
  end
end
