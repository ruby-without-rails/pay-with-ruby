require 'digest/sha1'

require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module UsuarioModule

      # @class [Usuario]
      class Usuario < BaseModel

        # Set Usuario dataset:
        set_dataset DB[:usuario]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:perfil, class: 'PayWithRuby::Models::UsuarioModule::Perfil', key: :perfil_id)

        # def initialize; end

        def before_save
          super
          atualizar_nome_pesquisa(self)
        end

        def atualizar_nome_pesquisa(usuario)
          usuario[:nome_consulta] = StringUtils.remove_accents(usuario[:nome].downcase)
        end

        class << self
          def salvar_usuario(dados_usuario)
            symbolize_keys!(dados_usuario)

            perfil = Perfil.obter_perfil_por_codigo(dados_usuario[:perfil])
            raise ModelException, 'O codigo do perfil é obrigatório.' unless perfil

            senha_original = dados_usuario[:password].empty? ? TokenUtils.gerar_numeros_letras_minusculas(6) : dados_usuario[:password]

            senha = Digest::SHA1.hexdigest(senha_original)

            usuario = User.new
            usuario.nome = dados_usuario[:nome]
            usuario.cpf = dados_usuario[:cpf]
            usuario.email = dados_usuario[:email]
            usuario.password = senha
            usuario.perfil_id = perfil.id
            usuario.data_hora_cadastro = Time.now

            usuario.save

            dados_usuario[:id] = usuario.id

            dados_usuario
          end

          def atualizar_usuario(dados_usuario)
            HashUtils.symbolize_keys!(dados_usuario)

            usuario = User.where(id: dados_usuario[:id]).first
            raise ModelException, 'Impossível de atualizar, usuário inexistente no banco de dados.' unless usuario

            perfil = Perfil.obter_perfil_por_codigo(dados_usuario[:perfil])
            raise ModelException, 'O codigo do perfil é obrigatório.' unless perfil

            usuario.update(cpf: dados_usuario[:cpf], nome: dados_usuario[:nome],
                           email: dados_usuario[:email], perfil_id: perfil[:id],
                           nome_consulta: StringUtils.remove_accents(dados_usuario[:nome].downcase))

            usuario.update(password: Digest::SHA1.hexdigest(dados_usuario[:password])) if dados_usuario[:password]

            usuario
          end

          def salvar_ou_atualizar_usuario(body_params)
            if body_params[:id].nil? || body_params[:id].zero?
              usuario = User.salvar_usuario(body_params)
              { mensagem: "Usuário foi salvo com sucesso com id: #{usuario[:id]}" }
            else
              usuario = User.atualizar_usuario(body_params)
              { mensagem: "Usuário com id: #{usuario[:id]} foi atualizado com sucesso."}
            end
          end

          def login_usuario(dados_login)
            symbolize_keys!(dados_login)

            usuario = DB[:usuario]
                          .select(:id, :nome, :cpf, :email, :perfil_id, :data_hora_cadastro)
                          .where(email: dados_login[:email], password: Digest::SHA1.hexdigest(dados_login[:password]), data_hora_exclusao: nil).first

            usuario
          end

          def obter_usuario_por_id_as_object(usuario_id)
            User.where(id: usuario_id).first
          end

          def obter_usuario_por_id(usuario_id)
            usuario = DB[:usuario]
                          .select(Sequel.qualify(:usuario, :id), :cpf, :nome, :email,
                                  Sequel.qualify(:usuario, :perfil_id), :data_hora_cadastro,
                                  Sequel.qualify(:perfil, :descricao),
                                  Sequel.qualify(:perfil, :codigo))
                          .join(:perfil, id: Sequel.qualify(:usuario, :perfil_id))
                          .where(Sequel.qualify(:usuario, :id) => usuario_id).first

            return_data = if usuario
                            {
                                id: usuario[:id],
                                cpf: usuario[:cpf],
                                nome: usuario[:nome],
                                email: usuario[:email],
                                data_hora_cadastro: usuario[:data_hora_cadastro],
                                perfil: {
                                    id: usuario[:perfil_id],
                                    descricao: usuario[:descricao],
                                    codigo: usuario[:codigo]
                                }
                            }
                          else
                            {}
                          end

            return_data
          end

          # Pequisa por usuarios
          def pesquisar_usuario(body_params)
            query = '(nome_consulta LIKE :query OR cpf LIKE :query OR email LIKE :query)'

            body_params[:query] = StringUtils.remove_accents(body_params[:query])

            body_params[:query].downcase!

            usuarios = DB[:usuario]
                           .join(:perfil, id: Sequel.qualify(:usuario, :perfil_id))
                           .extension(:pagination)
                           .select(Sequel.qualify(:usuario, :id),
                                   Sequel.qualify(:usuario, :cpf),
                                   Sequel.qualify(:usuario, :nome),
                                   Sequel.qualify(:usuario, :email),
                                   Sequel.qualify(:usuario, :data_hora_cadastro),
                                   Sequel.qualify(:perfil, :id).as(:perfil_id),
                                   Sequel.qualify(:perfil, :descricao),
                                   Sequel.qualify(:perfil, :codigo))
                           .where(Sequel.lit(query, query: "%#{body_params[:query]}%"))
                           .where(Sequel.qualify(:usuario, :data_hora_exclusao) => nil)

            total_itens = usuarios.count

            usuarios = usuarios.paginate(body_params[:pagina].to_i, 20)

            array_usuarios = []

            usuarios.all.each do |usuario|
              data = {
                  id: usuario[:id],
                  cpf: usuario[:cpf],
                  nome: usuario[:nome],
                  email: usuario[:email],
                  data_hora_cadastro: usuario[:data_hora_cadastro],
                  perfil: {
                      id: usuario[:perfil_id],
                      descricao: usuario[:descricao],
                      codigo: usuario[:codigo]
                  }
              }

              array_usuarios << data
            end

            return_data = {
                totalItens: total_itens,
                usuarios: array_usuarios
            }
            return_data
          end

          def alterar_senha(body_params, token, usuario)
            HashUtils.symbolize_keys!(body_params)

            is_valid = usuario.password.eql? Digest::SHA1.hexdigest(body_params[:password])

            raise ModelException, 'Impossível alterar a senha. Senha incorreta.' unless is_valid

            usuario = usuario.update(password: Digest::SHA1.hexdigest(body_params[:new_password]))

            invalidar_token(token)

            usuario
          end

          # Desabilitar usuario
          def desabilitar_usuario(usuario_id)
            usuario = User.where(id: usuario_id).where(data_hora_exclusao: nil).first
            usuario.update(data_hora_exclusao: Time.now) if usuario

            retorno = { msg: 'Usuário excluído com sucesso' } if usuario
            retorno ||= { msg: 'Usuário não encontrado' }
            retorno
          end

          def listar_usuarios_desabilitados
            User.exclude(data_hora_exclusao: nil).all.map(&:values)
          end

          def lista_usuarios_paginada(body_params)
            pagina = body_params[:pagina] || 1
            limite = body_params[:limite] || 20
            usuarios = DB[:usuario].join(:perfil, id: Sequel.qualify(:usuario, :perfil_id))
                           .select(Sequel.qualify(:usuario, :id),
                                   Sequel.qualify(:usuario, :cpf),
                                   Sequel.qualify(:usuario, :nome),
                                   Sequel.qualify(:usuario, :email),
                                   Sequel.qualify(:usuario, :data_hora_cadastro),
                                   Sequel.qualify(:perfil, :id).as(:perfil_id),
                                   Sequel.qualify(:perfil, :descricao),
                                   Sequel.qualify(:perfil, :codigo))
                           .extension(:pagination).where(data_hora_exclusao: nil).order(:nome)
            total_itens = usuarios.count
            usuarios = usuarios.paginate(pagina.to_i, limite).all

            array_usuarios = []

            usuarios.each do |u|
              array_usuarios << { id: u[:id], email: u[:email], cpf: u[:cpf], nome: u[:nome],
                                  perfil: { id: u[:perfil_id], descricao: u[:descricao], codigo: u[:codigo] } }
            end

            { totalItens: total_itens, usuarios: array_usuarios }
          end

          private

          def invalidar_token(token)
            user_token = DB[:user_token].where(token: token)
            user_token.delete if user_token
          end
        end
      end

      # @class [Perfil]
      class Perfil < BaseModel
        # Set Perfil dataset:
        set_dataset DB[:perfil]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        class << self
          def salvar_perfil(dados_perfil)
            perfil = Perfil.new
            perfil.descricao = dados_perfil[:descricao]
            perfil.codigo = dados_perfil[:codigo]

            perfil.save
            perfil
          end

          def listar_perfis
            perfis = Perfil.all.map(&:values)
            { perfis: perfis  }
          end

          def obter_perfil_por_id(perfil_id)
            Perfil.where(id: perfil_id).first
          end

          def obter_perfil_por_codigo(codigo)
            Perfil.where(codigo: codigo).first
          end

          def obter_perfil_por_nome(descricao)
            Perfil.where(descricao: descricao).first
          end
        end
      end
    end
  end
end
