require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module OrderModule

      class Order < BaseModel
        # Set Order dataset:
        set_dataset DB[:orders]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:customer, class: 'PayWithRuby::Models::CustomerModule::Customer', key: :customer_id)

        def initialize
          super
        end

        def after_initialize
          self.cart = JSON.parse(self.cart) unless self.cart.nil?
        end

        def validate
          super
          errors.add(:total, 'cannot be null') if total.nil?
          errors.add(:total, 'cannot be zero') if total and total.zero?
          errors.add(:total, 'must be greater than zero') if total and total < 0

          errors.add(:discount, 'cannot be null') if discount.nil?
          errors.add(:discount, 'must be greater than zero') if discount and discount < 0

          errors.add(:cart, 'cannot be null') if cart.nil?
          errors.add(:cart, 'cannot be empty') if cart and cart.empty?
        end

        def before_validate
          self.cart = JSON.generate(self.cart)
        end

        def before_save
          self.cart = JSON.generate(self.cart)
        end

        def after_save
          self.cart = JSON.parse(self.cart)
        end

        class << self
          def save_order(order_data, request_token)
            order = Order.new

            order.created_at = Time.now
            order.discount = order_data[:discount]
            order.total = order_data[:total]
            order.cart = order_data[:cart]

            # customer_id_or_name = order_data[:customer]
            #
            # raise ModelException, 'Um id ou nome de Cliente deve ser informado' if customer_id_or_name.nil?
            #
            # if customer_id_or_name.match?(/\d/)
            #   customer = Customer.get_customer_by_id(customer_id_or_name, false)
            # else
            #   customer = Customer.get_customer_by_name(customer_id_or_name, false)
            # end

            access_token = ApiAuther.identify(request_token)
            customer = access_token.customer

            raise ModelException, 'Cliente não encontrado.' unless customer

            order.customer = customer

            if order.valid?
              order.save
              message = order.exists? ? 'Pedido foi atualizado com sucesso!' : 'Pedido foi salvo com sucesso!'
              {order: order.values, message: message}
            else
              {validation_errors: order.errors}
            end
          end

          def get_order_by_id(order_id, for_api = true)
            order = Order[order_id]

            if for_api
              {order: order.nil? ? {} : order.values}
            else
              order
            end
          end

          def list_orders(request_token)
            access_token = ApiAuther.identify(request_token)
            orders = Order.where(canceled_at: nil)

            if access_token.user
              orders = orders.all
            elsif access_token.customer
              orders = orders.where(customer_id: access_token.customer.id).all
            else
              raise ModelException, 'Não foi possível identificar o usuário.'
            end

            {orders: orders.map(&:values)}
          end

          def list_canceled_orders
            {orders: Order.exclude(canceled_at: nil).all.map(&:values)}
          end

          def cancel_order(order_id)
            order = Order[order_id]
            order.canceled_at = Time.now if order

            msg = order.nil? ? "Pedido com o id: #{order_id} não encontrado" : "Pedido com id: #{order_id} foi cancelado com sucesso"

            {msg: msg}
          end
        end
      end
    end
  end
end
