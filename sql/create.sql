create table roles(
  id bigserial not null
    constraint roles_pkey
    primary key,
  description varchar(50) not null
    constraint role_description_key
    unique,
  code varchar(30) not null
);

create table users(
  id bigserial not null
    constraint users_pkey
    primary key,
  email varchar(100) not null,
  password varchar(100) not null,
  created_at timestamp default now() not null,
  deleted_at timestamp,
  cpf varchar(25) default 0 not null,
  role_id bigint default 1 not null
    constraint users__role_role_id_fkey
    references roles,
  name varchar(100) default ''::character varying not null,
  query_name varchar(255) not null,
  constraint users_email_deleted_at_key
  unique (email, deleted_at)
);

create table user_tokens(
  id bigserial not null
    constraint user_tokens_pkey
    primary key,
  token varchar(255),
  user_id bigint not null
    constraint user_tokens_user_id_fkey
    references users,
  expiration_time timestamp not null
);

