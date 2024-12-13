CREATE TABLE transaction.payment_method (
	pm_id SERIAL PRIMARY KEY,
	method_name VARCHAR(10) NOT NULL,
	CHECK(method_name IN('Cash','Bank','MFS'))
);

CREATE TABLE transaction.mfs_record (
	mfsr_id SERIAL PRIMARY KEY,
	mfs_provider VARCHAR(25) NOT NULL,
	CHECK(mfs_provider IN('Bkash','Nagad','Upay','Rocket','Tap')),
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE transaction.mfs_transaction ( -- redirects to this if payment_method = MFS
	mfst_id SERIAL PRIMARY KEY,
	provider INTEGER REFERENCES transaction.mfs_record(mfsr_id) NOT NULL,
	date TIMESTAMP, -- Date of transaction
	amount DECIMAL(10,2) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	sending_number INT NOT NULL,
	recipient_number INT NOT NULL,
	recipient_name VARCHAR(50) NOT NULL,
	remark VARCHAR(200),
	approved_by INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE transaction.cash_transaction ( -- redirects to this if payment_method = Cash
	ct_id SERIAL PRIMARY KEY,
	date TIMESTAMP, -- Date of transaction
	amount DECIMAL(10,2) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	recipient_name VARCHAR(50) NOT NULL,
	remark VARCHAR(200),
	approved_by INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE transaction.bank (
	bank_id SERIAL PRIMARY KEY,
	country INTEGER REFERENCES company.country(country_id) NOT NULL,
	bank_name VARCHAR(50) NOT NULL
);

CREATE TABLE transaction.bank_account (
	ba_id SERIAL PRIMARY KEY,
	bank INTEGER REFERENCES transaction.bank(bank_id),
	owning_entity VARCHAR(25) NOT NULL, -- who owns the bank account
	CHECK(owning_entity IN('Own','Employee','Supplier','Vendor')),
	account_alias VARCHAR(20) NOT NULL,
	account_name VARCHAR(100) NOT NULL,
	account_number INT NOT NULL,
	branch_name VARCHAR(25) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE transaction.bank_transaction ( -- redirects to this if payment_method = Bank
	bt_id SERIAL PRIMARY KEY,
	date TIMESTAMP, -- date of transaction
	from_account INTEGER REFERENCES transaction.bank_account(ba_id), -- account_alias can be used from front end
	to_account INTEGER REFERENCES transaction.bank_account(ba_id), -- account_alias can be used from Front end
	amount DECIMAL(10,2) NOT NULL,
	remark VARCHAR(200),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP,
	approved_by INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);