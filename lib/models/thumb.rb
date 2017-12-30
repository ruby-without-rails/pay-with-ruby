require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module ProductModule

      class Thumb < BaseModel
        # Set Thumb dataset:
        set_dataset DB[:thumbs]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        class << self

        end
      end
    end
  end
end
