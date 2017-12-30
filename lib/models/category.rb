require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module ProductModule

      class Category < BaseModel
        # Set Category dataset:
        set_dataset DB[:categories]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        def validate
          super
          errors.add(:name, 'cannot be null') if name.nil?
          errors.add(:name, 'must be a String') if name and name.match?(/\d/)
          errors.add(:name, 'cannot be empty') if name and not name.match?(/\d/) and name.empty?
          errors.add(:name, 'must be have 6 characters') if name and not name.match?(/\d/) and name.size < 6
        end

        class << self
          def save_category(category_data)
            id = category_data[:id]

            if not id.nil? or not id.match?(/\d/)
              category = Category[id]
            else
              category = Category.new
            end

            category.name = category_data[:name]

            if category.valid?
              category.save
              message = category.new? ? 'Categoria foi salva com sucesso!' : 'Categoria foi atualizada com sucesso!'
              { category: category.values, message: message }
            else
              { validation_errors: category.errors }
            end
          end

          def get_category_by_id(category_id)
            category = Category[category_id]
            { category: category.nil? ? {} : category.values }
          end

          def get_category_by_name(category_name)
            category = Category.where(name: category_name).first
            { category: category.nil? ? {} : category.values }
          end

          def find_categories_by_name(category_name)
            categories = Category.where(Sequel.ilike(name: "%#{category_name}%")).all
            { categories: categories.nil? ? {} : categories.map(&:values) }
          end

          def list_categories
            { categories: Category.all.map(&:values) }
          end

          def delete_category(category_id)
            category = Category[category_id]
            category.delete if category

            msg = category.nil? ? "Categoria com o id: #{category_id} não encontrada" : "Categoria com id: #{category_id} excluída com sucesso"

            { msg: msg }
          end
        end
      end
    end
  end
end
