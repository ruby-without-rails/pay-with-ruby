module BaseRoutes
  class << self
    def included(controller)
      controller.include PayWithRuby::Helpers::ApiHelper::ApiBuilder
      controller.include PayWithRuby::Helpers::ApiHelper::ApiValidation
      controller.include PayWithRuby::Helpers::ApiHelper::ApiAccess
    end
  end
end