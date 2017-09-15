# frozen_string_literal: true

module Salesforce
  class SupporterData
    TABLE_NAME = 'Contact'

    def initialize(data)
      @data = data
    end

    def fields
      return unless valid_data?
      {
        LastName: data.name,
        Email: data.email
      }
    end

    def errors
      validation_errors = []
      validation_errors << :invalid_last_name unless data.name
      validation_errors << :invalid_email unless data.email
      validation_errors.compact
    end

    private

    attr_reader :data

    def valid_data?
      errors.empty?
    end
  end
end
