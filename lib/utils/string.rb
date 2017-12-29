require 'erb'
require 'mustache'
require 'ostruct'
require 'i18n'

module PayWithRuby
  module Utils
    # Utility methods for String manipulation
    module String
      class << self
        # Replace variables from string using Ruby's Sprintf
        #
        # @param [String] string
        # @param [Hash, Array] vars
        # @return [String]
        def replace_vars(string, vars)
          string % vars
        end

        # Replace variables from string using Ruby's ERB
        #
        # @param [String] string
        # @param [Hash] vars
        # @return [String]
        def replace_erb(string, vars)
          ERB.new(string).result(OpenStruct.new(vars).instance_eval { binding })
        end

        # Replace variables from string using Mustache
        #
        # @param [String] string
        # @param [Hash] vars
        # @return [String]
        def replace_mustache(string, vars)
          Mustache.render(string, vars)
        end

        def generate_random_string(quantity)
          token = ''

          for i in 1..100 do
            begin
              # Create a random writeable string, with 1024 characters:
              o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten

              token = (0...quantity).map { o[rand(o.length)] }.join

              stop = true
            rescue StandardError
              stop = false
            end

            break if stop
          end

          token
        end

        def capitalize(value)
          value.split.map(&:capitalize).join(' ')
        end

        # Convert a string to lower case and replace
        # spaces with underscore
        #
        # @param [String] string
        # @return [String]
        def snake_case(string)
          string
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .gsub(/\s/, '_')
            .gsub(/__+/, '_')
            .downcase
        end

        # Return a new string with the accents removed
        #
        # @param [String] string
        # @return [String]
        def remove_accents(string)
          I18n.available_locales = [:en]
          I18n.transliterate(string)
        end

        # Retorna uma Nova String com Zeros a Esquerda
        # @return [String]
        # @param valor Numero a ser acrescido de Zeros
        # @param limite [Fixnum] Valor Limite de Zeros
        def preencher_com_zeros(valor, limite)
          valor = valor.to_s

          zeros = ''

          tamanho_string = valor.size

          for v in tamanho_string..limite
            zeros << '0' if v < limite
          end
          zeros.concat(valor)
        end

        # Retorna CPF ou CNPJ formatado
        def obter_cpf_cnpj_formatado(cpf_cnpj)
          return cpf_cnpj if cpf_cnpj.include?('.') || cpf_cnpj.include?('-')

          if cpf_cnpj.length.eql?(11)
            return cpf_cnpj.insert(3, '.').insert(7, '.').insert(11, '-')
          end

          if cpf_cnpj.length.eql?(14)
            return cpf_cnpj.insert(2, '.').insert(6, '.').insert(10, '/').insert(15, '-')
          end

          cpf_cnpj
        end
      end
    end
  end
end
