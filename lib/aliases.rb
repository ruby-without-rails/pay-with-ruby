# Aliases for Utils
TokenUtils = PayWithRuby::Utils::Token
LoggerUtils = PayWithRuby::Utils::Logger
StringUtils = PayWithRuby::Utils::String
HashUtils = CodeCode::Common::Utils::Hash

# Aliases for Models classes

# auth.rb
AccessToken = PayWithRuby::Models::AuthModule::AccessToken
ApiAuther = PayWithRuby::Models::AuthModule::ApiAuther

# category.rb
Category = PayWithRuby::Models::ProductModule::Category

# configuration.rb
Configuration = PayWithRuby::Models::ConfigurationModule::Configuration

# customer.rb
Customer = PayWithRuby::Models::CustomerModule::Customer

# order.rb
Order = PayWithRuby::Models::OrderModule::Order

# product.rb
Product = PayWithRuby::Models::ProductModule::Product

# role.rb
Role = PayWithRuby::Models::UserModule::Role

# startup.rb
StartupConfig = PayWithRuby::Models::ConfigurationModule::StartupConfig.instance

# thumb.rb
Thumb = PayWithRuby::Models::ProductModule::Thumb

# user.rb
User = PayWithRuby::Models::UserModule::User


# Mundipagg Gateways
# payment.rb
Payment = PayWithRuby::Gateways::Payment::MundiPagg::Payment
OnlineDebitTransaction = PayWithRuby::Gateways::Payment::MundiPagg::OnlineDebitTransaction
CreditCard = PayWithRuby::Gateways::Payment::MundiPagg::CreditCard