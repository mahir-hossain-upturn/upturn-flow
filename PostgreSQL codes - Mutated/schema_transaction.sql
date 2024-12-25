CREATE TABLE IF NOT EXISTS transaction.payment_method (
	id SERIAL PRIMARY KEY,
	name VARCHAR(10) NOT NULL,
	CHECK(name IN('Cash','Bank','MFS'))
);

CREATE TABLE IF NOT EXISTS transaction.mfs_record (
	id SERIAL PRIMARY KEY,
	provider VARCHAR(25) NOT NULL,
	CHECK(provider IN('Bkash','Nagad','Upay','Rocket','Tap')),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS transaction.mfs_transaction ( -- redirects to this if payment_method = MFS
	id SERIAL PRIMARY KEY,
	provider VARCHAR(25) REFERENCES transaction.mfs_record(provider) NOT NULL,
	date TIMESTAMP, -- Date of transaction
	amount DECIMAL(10,2) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	sending_number INT NOT NULL,
	recipient_number INT NOT NULL,
	recipient_name VARCHAR(50) NOT NULL,
	remark VARCHAR(200),
	approved_by_id uuid REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS transaction.cash_transaction ( -- redirects to this if payment_method = Cash
	id SERIAL PRIMARY KEY,
	date TIMESTAMP, -- Date of transaction
	amount DECIMAL(10,2) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	recipient_name VARCHAR(50) NOT NULL,
	remark VARCHAR(200),
	approved_by_id uuid REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS transaction.bank (
	id SERIAL PRIMARY KEY,
	country_id INTEGER REFERENCES company.country(id) NOT NULL,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS transaction.bank_account (
	id SERIAL PRIMARY KEY,
	bank_id INTEGER REFERENCES transaction.bank(id),
	owning_entity VARCHAR(25) NOT NULL, -- who owns the bank account
	CHECK(owning_entity IN('Own','Employee','Supplier','Vendor')),
	alias VARCHAR(20) NOT NULL,
	name VARCHAR(100) NOT NULL,
	account_number INT NOT NULL,
	branch_name VARCHAR(25) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS transaction.bank_transaction ( -- redirects to this if payment_method = Bank
	id SERIAL PRIMARY KEY,
	date TIMESTAMP, -- date of transaction
	from_account_id INTEGER REFERENCES transaction.bank_account(id), -- account_alias can be used from front end
	to_account_id INTEGER REFERENCES transaction.bank_account(id), -- account_alias can be used from Front end
	amount DECIMAL(10,2) NOT NULL,
	remark VARCHAR(200),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	approved_by_id uuid REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);