require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module ProductModule

      class Product < BaseModel
        # Set Product dataset:
        set_dataset DB[:products]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:category, class: 'PayWithRuby::Models::ProductModule::Category', key: :category_id)

        # def initialize; end

        def validate
          super
          errors.add(:name, 'cannot be null') if name.nil?
          errors.add(:name, 'must be a String') if name and name.match?(/\d/)
          errors.add(:name, 'cannot be empty') if name and not name.match?(/\d/) and name.empty?
          errors.add(:name, 'must be have 6 characters') if name and not name.match?(/\d/) and name.size < 6

          errors.add(:description, 'cannot be null') if description.nil?
          errors.add(:description, 'must be a String') if description and not description.match?(/\w/)
          errors.add(:description, 'cannot be empty') if description and not description.match?(/\d/) and description.empty?
        end

        class << self
          def save_product(product_data)
            id = product_data[:id]

            if not id.nil? and id.match?(/\d/)
              product = Product[id]
            else
              product = Product.new
            end

            product.name = product_data[:name]
            product.description = product_data[:description]
            category_id_or_name = product_data[:category]

            raise ModelException, 'Um id ou nome de categoria deve ser informado' if category_id_or_name.nil?

            if category_id_or_name.match?(/\d/)
              category = Category.get_category_by_id(category_id_or_name, false)
            else
              category = Category.get_category_by_name(category_id_or_name, false)
            end

            raise ModelException, "Categoria não encontrada." unless category

            product.category = category

            if product.valid?
              product.save
              message = product.exists? ? 'Produto foi atualizado com sucesso!' : 'Produto foi salvo com sucesso!'
              {product: product.values, message: message}
            else
              {validation_errors: product.errors}
            end
          end

          def get_product_by_id(product_id)
            product = Product[product_id]
            {product: product.nil? ? {} : product.values}
          end

          def list_products
            {products: Product.all.map(&:values)}
          end

          def delete_product(product_id)
            product = Product[product_id]
            product.delete if product

            msg = product.nil? ? "Produto com o id: #{product_id} não encontrado" : "Produto com id: #{product_id} excluído com sucesso"

            {msg: msg}
          end
        end
      end
    end
  end
end
