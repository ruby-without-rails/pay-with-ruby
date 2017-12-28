require 'utils/api_helper'

module MundiPaggRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Utils::ApiHelper
      controller.namespace('/mp'){|c|
        c.get('/hello') {
          make_default_json_api(self)
        }
      }

    end
  end
end