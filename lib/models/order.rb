require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module OrderModule

      class Order < BaseModel
        # Set Customer dataset:
        set_dataset DB[:orders]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:customer, class: 'PayWithRuby::Models::CustomerModule::Customer', key: :customer_id)

        # def initialize; end

        def validate
          super
        end

        class << self
          def save_order(order_data)
            order = Order.new

            order.created_at = Time.now
            order.discount = order_data[:discount]
            order.total = order_data[:total]
            customer_id_or_name = order_data[:customer]

            raise ModelException, 'Um id ou nome de Cliente deve ser informado' if customer_id_or_name.nil?

            if customer_id_or_name.match?(/\d/)
              customer = Customer.get_customer_by_id(customer_id_or_name, false)
            else
              customer = Customer.get_customer_by_name(customer_id_or_name, false)
            end

            raise ModelException, "Cliente não encontrada." unless customer

            order.customer = customer


            if order.valid?
              order.save
              message = order.exists? ? 'Pedido foi atualizado com sucesso!' : 'Pedido foi salvo com sucesso!'
              {order: order.values, message: message}
            else
              {validation_errors: order.errors}
            end
          end

          def get_order_by_id(order_id)
            order = Order[order_id]
            {order: order.nil? ? {} : order.values}
          end

          def list_orders
            {orders: Order.where(canceled_at: nil).all.map(&:values)}
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
