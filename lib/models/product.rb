require 'requires'

module PayWithRuby
  module Models
    module ProductModule
      include PayWithRuby::Models::Base

      class Product < BaseModel
        # Set Product dataset:
        set_dataset DB[:products]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        class << self

        end
      end
    end
  end
end
