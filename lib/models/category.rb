require 'requires'

module PayWithRuby
  module Models
    module ProductModule
      include PayWithRuby::Models::Base

      class Category < BaseModel
        # Set Category dataset:
        set_dataset DB[:categories]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        class << self
          def save_category(category_data)
            category = Category.new
            category.name = category_data[:name]

            category.save
            category
          end

          def get_category_by_id(category_id)
            category = Category[category_id]
            {category: category.nil? ? {} : category}
          end

          def list_categories
            {categories: Category.all.map(&:values)}
          end

          def delete_category(category_id)
            category = Category[category_id]
            category.delete if category

            msg = category.nil? ? "Categoria com o id: #{category_id} não encontrada" : "Categoria com id: #{category_id} excluída com sucesso"

            {msg: msg}
          end
        end
      end
    end
  end
end
