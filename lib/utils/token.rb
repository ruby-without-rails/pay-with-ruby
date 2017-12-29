module PayWithRuby
  module Utils
    # Utility methods for token generation
    module Token
      class << self
        def generate(length = 256)
          o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten

          token = (0...length).map { o[rand(o.length)] }.join

          token
        end

        def gerar_numeros_letras_minusculas(length = 256)
          o = [('a'..'z'), ('0'..'9')].map(&:to_a).flatten

          token = (0...length).map { o[rand(o.length)] }.join

          token
        end

        def gerar_codigo_campanha_parceiro
          l = [('A'..'Z')].map(&:to_a).flatten
          letras = (0...3).map { l[rand(l.length)] }.join

          n = [('0'..'9')].map(&:to_a).flatten
          numeros = (0...4).map { n[rand(n.length)] }.join

          "#{letras}#{numeros}"
        end
      end
    end
  end
end
