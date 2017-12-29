module MundiPaggRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.get('/') {
        file_path = File.join(settings.public_folder, 'mundipagg.html')
        if File.exist?(file_path) and File.readable?(file_path)
          send_file file_path
        else
          'Arquivo não encontrado!'
        end
      }

      controller.get('/cobranca/:id_cobranca') {
        make_default_json_api(self)
      }

      controller.get('/cobrancas/listar/:pagina') {
        make_default_json_api(self)
      }

      controller.post('/cobranca') {
        make_default_json_api(self)
      }
    end
  end
end