require 'codecode/common/utils'

# %w{helpers models routes utils}.each { |dir| Dir.glob("#{dir}/*.rb", &method(:require)) }

# Utils import:
require 'utils/discover_os'
require 'utils/logger'
require 'utils/string'
require 'utils/token'

# Helpers import:
require 'helpers/api_helper'

# Models import:
require 'models/base'
require 'models/auth'
require 'models/access_token'
require 'models/category'
require 'models/configuration'
require 'models/customer'
require 'models/order'
require 'models/product'
require 'models/role'
require 'models/startup_config'
require 'models/thumb'
require 'models/user'

# mundipagg
require 'gateways/mundipagg/models/payment'

require 'aliases'
