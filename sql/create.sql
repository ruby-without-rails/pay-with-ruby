-- Criação da tabela usuario
create table usuario (
  id bigserial primary key,
  nome character varying(100) NOT NULL,
  username character varying(100) NOT NULL,
  password character varying(100),
  data_hora_cadastro timestamp without time zone NOT NULL DEFAULT now(),
  data_hora_exclusao timestamp without time zone
);

-- Adicionando tabela de user_token para filtro de requisições
Create table user_token (
  id bigserial PRIMARY KEY,
  token character varying(255),
  usuario_id bigint NOT NULL ,
  data_hora_expiracao timestamp without time zone NOT NULL,
  CONSTRAINT user_token_usuario_id_fkey FOREIGN KEY (usuario_id)
  REFERENCES users (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Adicionando tabela perfil de usuário
create table perfil(
  id bigserial not null
    constraint perfil_pkey
    primary key,
  descricao VARCHAR(30) NOT NULL
);

ALTER TABLE roles ADD UNIQUE (description);

ALTER TABLE roles ADD codigo VARCHAR(30) NULL;
ALTER TABLE roles ALTER COLUMN description TYPE VARCHAR(50) USING description::VARCHAR(50);
ALTER TABLE roles ALTER COLUMN code SET NOT NULL;

-- Alterações na tabela de usuário
ALTER TABLE users RENAME COLUMN username TO email;
ALTER TABLE users ALTER COLUMN email SET NOT NULL ;
ALTER TABLE users RENAME COLUMN password TO senha;
ALTER TABLE users ALTER COLUMN senha SET NOT NULL ;
ALTER TABLE users ADD COLUMN cpf varchar(25) NOT NULL DEFAULT 0;
ALTER TABLE users ADD UNIQUE (email);
ALTER TABLE users DROP COLUMN name;
ALTER TABLE users ADD COLUMN perfil_id bigint NOT NULL DEFAULT 1;
ALTER TABLE users ADD CONSTRAINT usuario__perfil_perfil_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) MATCH SIMPLE;

-- Alterações Tabela usuario
ALTER TABLE users RENAME COLUMN senha TO password;
ALTER TABLE users ADD COLUMN nome varchar(100) NOT NULL DEFAULT '';


-- Correcao na tabela usuarios
ALTER TABLE users DROP CONSTRAINT usuario_email_key;
ALTER TABLE users ADD CONSTRAINT usuario_email_exclusao_key UNIQUE(email, deleted_at);

-- Adicionando campo pesquisável na tabela de consulta
ALTER TABLE users ADD COLUMN nome_consulta varchar(255);
