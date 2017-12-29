require 'helpers/api_helper'

module VindiRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.get('/') {
        file_path = File.join(settings.public_folder, 'vindi.html')
        if File.exist?(file_path) and File.readable?(file_path)
          send_file file_path
        else
          'Arquivo não encontrado!'
        end
      }

      controller.namespace('/vindi') {|c|
        c.get('/cobranca/:id_cobranca'){
          make_default_json_api(self)
        }

        c.get('/cobrancas/listar/:pagina'){
          make_default_json_api(self)
        }

        c.post('/cobranca') {
          make_default_json_api(self)
        }
      }
    end
  end
end