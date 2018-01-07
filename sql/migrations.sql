ALTER TABLE categories ADD CONSTRAINT categories_id_pk PRIMARY KEY (id);
ALTER TABLE products ADD image VARCHAR(255) DEFAULT '' NOT NULL;
ALTER TABLE customers ADD mobile_phone_number VARCHAR(60) NULL;