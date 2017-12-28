module MundiPaggRoutes
  class << self
    def extended(controller)
      controller.namespace('/mp'){|c|
        c.get('/hello') {
          [200, 'Hello i m here']
        }
      }

    end
  end
end