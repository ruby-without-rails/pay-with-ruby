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

        def after_initialize
          Category.prepare_image(self) unless self.new?
        end

        def validate
          super
          errors.add(:name, 'cannot be null') if name.nil?
          errors.add(:name, 'must be a String') if name and name.match?(/\d/)
          errors.add(:name, 'cannot be empty') if name and not name.match?(/\d/) and name.empty?
          errors.add(:name, 'must be have 5 characters') if name and not name.match?(/\d/) and name.size < 5
        end

        class << self

          def prepare_image(category)
            if category.is_a?(Category)
              unless category.new?
                if not category.thumb.nil?
                  if not category.thumb.empty?
                    category.thumb.gsub!('{host}', StartupConfig.request_host)
                  end
                end
                category
              end
            else
              if category.has_key?(:thumb)
                if not category[:thumb].nil?
                  if not category[:thumb].empty?
                    category[:thumb].gsub!('{host}', StartupConfig.request_host)
                  end
                end
              end
            end
          end

          def save_category(category_data)
            id = category_data[:id]

            if not id.nil? and id.to_s.match?(/\d/)
              category = Category[id]
            else
              category = Category.new
            end

            category.name = category_data[:name]
            category.title = category_data[:title]
            category.subtitle = category_data[:subtitle]
            category.thumb = category_data[:thumb]

            if category.valid?
              category.save
              message = category.exists? ? 'Categoria foi atualizada com sucesso!' : 'Categoria foi salva com sucesso!'
              prepare_image(category)
              {category: category.values, message: message}
            else
              {validation_errors: category.errors}
            end
          end

          # @param [Boolean] for_api
          def get_category_by_id(category_id, for_api = true)
            category = Category[category_id]

            if for_api
              if category.nil?
                category = {}
              else
                prepare_image(category)
                category = category.values
              end
              {category: category}
            else
              category
            end
          end

          # @param [Boolean] for_api
          def get_category_by_name(category_name, for_api = true)
            category = Category.where(name: category_name).first

            if for_api
              if category.nil?
                category = {}
              else
                prepare_image(category)
                category = category.values
              end
              {category: category}
            else
              category
            end
          end

          def find_categories_by_name(category_name)
            categories = Category.where(Sequel.ilike(name: "%#{category_name}%")).all
            {categories: categories.nil? ? {} : categories.map(&:values)}
          end

          def list_categories
            categories = Category.all.map(&:values)
            categories.each {|c| prepare_image(c)}
            {categories: categories}
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
