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
require 'models/auth'
require 'models/access_token'
require 'models/category'
require 'models/customer'
require 'models/product'
require 'models/order'
require 'models/role'
require 'models/thumb'
require 'models/user'

require 'aliases'
