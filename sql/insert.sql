--Inserção dos perfis de usuários
INSERT INTO roles(description, code) VALUES('Operador','Operador');
INSERT INTO roles(description,code) VALUES('Administrador','Administrador');

INSERT INTO users (email, password, created_at, deleted_at, cpf, role_id, name, query_name)
VALUES ('felipe@codecode.com.br', '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-08-07 09:07:48.599000', null, '12345678912', 1, 'Felipe Code Code', 'felipe-code-code');

--Inserção de valor na tabela configuração
insert into configurations (name, value) values ('version', '0.0.1');

--MundiPagg
insert into configurations (name, value) values ('mundipagg_sand_base_url', 'https://sandbox.mundipaggone.com');
insert into configurations (name, value) values ('mundipagg_prod_base_url', 'https://transactionv2.mundipaggone.com');
insert into configurations (name, value) values ('api_key_mundipagg_prod','372984e7-1433-4492-aec4-0451682d3feb');
insert into configurations (name, value) values ('api_key_mundipagg_sand','372984e7-1433-4492-aec4-0451682d3feb');