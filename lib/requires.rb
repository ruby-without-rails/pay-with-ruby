require 'codecode/common/utils'

# %w{helpers models routes utils}.each { |dir| Dir.glob("#{dir}/*.rb", &method(:require)) }

# Utils import:
require 'utils/logger'
require 'utils/token'
require 'utils/discover_os'
require 'utils/string'

# Helpers import:
require 'helpers/api_helper'

# Models import:
require 'models/user'
require 'models/auth'
require 'models/category'

require 'aliases'
