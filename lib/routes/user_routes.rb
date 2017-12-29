module UserRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') {|c|
        c.post('/login') {
          make_default_json_api(self, @request_payload) {|params, _status_code|

            usuario = Usuario.login_usuario(params)

            if usuario
              _status_code = 200
              user_token = UserToken.salvar_user_token(usuario[:id])
              body = {token: user_token.token}
            else
              _status_code = 400
              body = {mensagem: 'Login ou senha inválidos'}
            end

            {status: _status_code, response: body}
          }
        }

        c.get('/logout') {
          make_default_json_api(self) {
            ApiAuther.unauthorize_or_raise(@request_token)
          }
        }

        c.post('/usuarios') {
          make_default_json_api(self, @request_payload) {|params, _status_code|
            {status: _status_code, response: Usuario.salvar_ou_atualizar_usuario(params)}
          }
        }

        c.namespace('/usuarios') {|c|
          c.get('/obter_dados_usuario') {
            make_default_json_api(self) {
              user_token = ApiAuther.identify(@request_token, true)
              usuario = Usuario.obter_usuario_por_id(user_token.usuario_id)
              {usuario: usuario}
            }
          }

          c.get('/perfil') {
            make_default_json_api(self) {
              Perfil.listar_perfis
            }
          }

          c.post('/pesquisa') {
            make_default_json_api(self, @request_payload) {|params, _status_code|
              {status: _status_code, response: Usuario.pesquisar_usuario(params)}
            }
          }

          c.delete('/:usuario_id') {|usuario_id|
            make_default_json_api(self) {
              raise UnexpectedParamException.new "Parâmetro de URL inesperado #{usuario_id}" unless usuario_id.match(/^\d+$/)

              Usuario.desabilitar_usuario(usuario_id)
            }
          }

          c.get('/lista-desabilitados') {
            make_default_json_api(self) {
              Usuario.listar_usuarios_desabilitados
            }
          }

          c.get('/:usuario_id') {|usuario_id|
            make_default_json_api(self) {
              raise UnexpectedParamException.new "Parâmetro de URL inesperado #{usuario_id}" unless usuario_id.match(/^\d+$/)

              Usuario.obter_usuario_por_id(usuario_id)
            }
          }

          c.post('/alterar-senha') {
            make_default_json_api(self, @request_payload) {|params, _status_code|

              user_token = ApiAuther.identify(@request_token, true)

              usuario = Usuario.obter_usuario_por_id_as_object(user_token[:usuario_id])

              usuario = Usuario.alterar_senha(params, @request_token, usuario) if usuario

              retorno = {mensagem: 'Senha alterada com sucesso.'} if usuario

              params[:email] = usuario[:email]

              retorno ||= {mensagem: 'Não foi possível alterar a senha'}

              {status: _status_code, response: retorno}
            }
          }

          c.post('/lista') {
            make_default_json_api(self, @request_payload) {|params, _status_code|
              {status: _status_code, response: Usuario.lista_usuarios_paginada(params)}
            }
          }
        }
      }
    end
  end
end
