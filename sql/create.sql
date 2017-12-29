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

create table categories(
  id serial not null,
  name varchar(100) not null
);

create unique index categories_id_uindex
  on categories (id);

create unique index categories_name_uindex
  on categories (name);

create table products(
  name varchar(255) not null,
  id bigserial not null
    constraint products_pkey
    primary key,
  description text not null,
  category_id bigint not null
    constraint products_categories_id_fk
    references categories (id)
);

create unique index products_id_uindex
  on products (id);

create table thumbs(
  id serial not null
    constraint thumbs_pkey
    primary key,
  product_id bigint not null
    constraint thumbs_products_id_fk
    references products,
  json_thumbs text not null
);

create unique index thumbs_id_uindex
  on thumbs (id);







