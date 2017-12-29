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
  REFERENCES usuario (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Adicionando tabela perfil de usuário
create table perfil(
  id bigserial not null
    constraint perfil_pkey
    primary key,
  descricao VARCHAR(30) NOT NULL
);

ALTER TABLE perfil ADD UNIQUE (descricao);

ALTER TABLE perfil ADD codigo VARCHAR(30) NULL;
ALTER TABLE perfil ALTER COLUMN descricao TYPE VARCHAR(50) USING descricao::VARCHAR(50);
ALTER TABLE perfil ALTER COLUMN codigo SET NOT NULL;

-- Alterações na tabela de usuário
ALTER TABLE usuario RENAME COLUMN username TO email;
ALTER TABLE usuario ALTER COLUMN email SET NOT NULL ;
ALTER TABLE usuario RENAME COLUMN password TO senha;
ALTER TABLE usuario ALTER COLUMN senha SET NOT NULL ;
ALTER TABLE usuario ADD COLUMN cpf varchar(25) NOT NULL DEFAULT 0;
ALTER TABLE usuario ADD UNIQUE (email);
ALTER TABLE usuario DROP COLUMN nome;
ALTER TABLE usuario ADD COLUMN perfil_id bigint NOT NULL DEFAULT 1;
ALTER TABLE usuario ADD CONSTRAINT usuario__perfil_perfil_id_fkey FOREIGN KEY (perfil_id) REFERENCES perfil (id) MATCH SIMPLE;

-- Alterações Tabela usuario
ALTER TABLE usuario RENAME COLUMN senha TO password;
ALTER TABLE usuario ADD COLUMN nome varchar(100) NOT NULL DEFAULT '';


-- Correcao na tabela usuarios
ALTER TABLE usuario DROP CONSTRAINT usuario_email_key;
ALTER TABLE usuario ADD CONSTRAINT usuario_email_exclusao_key UNIQUE(email, data_hora_exclusao);

-- Adicionando campo pesquisável na tabela de consulta
ALTER TABLE usuario ADD COLUMN nome_consulta varchar(255);
