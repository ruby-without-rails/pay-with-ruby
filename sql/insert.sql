--Inserção dos perfis de usuários
INSERT INTO roles(description, code) VALUES('Operador','Operador');
INSERT INTO roles(description,code) VALUES('Administrador','Administrador');

INSERT INTO users (email, password, created_at, deleted_at, cpf, role_id, name, query_name)
VALUES ('felipe@codecode.com.br', '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-08-07 09:07:48.599000', null, '12345678912', 1, 'Felipe Code Code', 'felipe-code-code');