require 'utils/api_helper'

module MundiPaggRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Utils::ApiHelper

      controller.get('/') {
        file_path = File.join(settings.public_folder, 'index.html')
        if File.readable?(file_path)
          send_file file_path
        else
          'Arquivo não encontrado!'
        end
      }

      controller.namespace('/mp') {|c|
        c.get('/hello') {
          make_default_json_api(self)
        }
      }

    end
  end
end