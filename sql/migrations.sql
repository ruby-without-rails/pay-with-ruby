ALTER TABLE categories ADD CONSTRAINT categories_id_pk PRIMARY KEY (id);
ALTER TABLE products ADD image VARCHAR(255) DEFAULT '' NOT NULL;
ALTER TABLE customers ADD mobile_phone_number VARCHAR(60) NULL;

ALTER TABLE access_tokens RENAME COLUMN token TO key;

-- Adding new fields for category
ALTER TABLE categories ADD title VARCHAR(100) NULL;
ALTER TABLE categories ADD subtitle VARCHAR(100) NULL;
ALTER TABLE categories ADD thumb VARCHAR(255) NULL;