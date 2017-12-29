--Inserção dos perfis de usuários
INSERT INTO perfil(descricao, codigo) VALUES('Operador','Operador');
INSERT INTO perfil(descricao,codigo) VALUES('Administrador','Administrador');

INSERT INTO usuario (email, password, data_hora_cadastro, data_hora_exclusao, cpf, perfil_id, nome, nome_consulta)
VALUES ('felipe@codecode.com.br', '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-08-07 09:07:48.599000', null, '12345678912', 1, 'Felipe Code Code', 'felipe-code-code');