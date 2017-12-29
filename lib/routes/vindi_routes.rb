module VindiRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.get('/') do
        file_path = File.join(settings.public_folder, 'vindi.html')
        if File.exist?(file_path) && File.readable?(file_path)
          send_file file_path
        else
          'Arquivo não encontrado!'
        end
      end

      controller.get('/cobranca/:id_cobranca') do
        make_default_json_api(self)
      end

      controller.get('/cobrancas/listar/:pagina') do
        make_default_json_api(self)
      end

      controller.post('/cobranca') do
        make_default_json_api(self)
      end
    end
  end
end
