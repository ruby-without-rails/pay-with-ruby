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

create table access_tokens(
  id bigserial not null
    constraint access_tokens_pkey
    primary key,
  token varchar(255),
  user_id bigint
    constraint access_tokens_user_id_fkey
    references users,
  expires_at timestamp not null,
  ip varchar(100) not null,
  customer_id bigint
    constraint access_tokens_customers_id_fk
    references customers
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

create table customers(
  id serial not null
    constraint customers_pkey
    primary key,
  name varchar(255) not null,
  cpf varchar(25) not null,
  fcm_id varchar(255) not null,
  email varchar(255) not null,
  created_at timestamp default now() not null,
  updated_at timestamp,
  deleted_at timestamp
);

create unique index customers_id_uindex
  on customers (id);

create table orders(
  id serial not null
    constraint orders_pkey
    primary key,
  created_at timestamp default now() not null,
  json_cart text not null,
  discount double precision default 0 not null,
  total double precision default 0 not null,
  customer_id bigint not null
    constraint orders_customers_id_fk
    references customers,
  canceled_at timestamp
);

create unique index orders_id_uindex
  on orders (id);

create table configurations(
  name varchar(100) not null
    constraint configurations_pkey
    primary key,
  value varchar(255) not null
);

create unique index configurations_name_uindex
  on configurations (name);