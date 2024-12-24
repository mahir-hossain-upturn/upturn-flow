CREATE TABLE IF NOT EXISTS stakeholder.type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    CHECK (name IN ('Client', 'Supplier', 'Lead', 'Vendor'))
);

CREATE TABLE IF NOT EXISTS stakeholder.category (
	id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    CHECK (name IN ('Prospective','One-time','Recurring','On-Hold','Discontinued'))
);

CREATE TABLE IF NOT EXISTS stakeholder.record (
	id SERIAL PRIMARY KEY,
    stakeholder_type_id INTEGER REFERENCES stakeholder.type(id) NOT NULL,
    category_id INTEGER REFERENCES stakeholder.category(id) NOT NULL,
    stakeholder_name VARCHAR(100) NOT NULL,
	description TEXT, -- details on the product / services being taken or rendered
    contact_person VARCHAR(50),
    email VARCHAR(50), -- data validation required
    phone VARCHAR(20), -- data validation required
	is_active BOOLEAN NOT NULL, -- currently taking service
	monthly_subscription BOOLEAN DEFAULT TRUE, -- only for (recurring and is_active)
	bill_same BOOLEAN DEFAULT TRUE,
	bill_amount DECIMAL(10,2), -- only when bill_same = true
	contract_start_date DATE,
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL -- ON UPDATE
);

CREATE TABLE IF NOT EXISTS stakeholder.interaction_p1 (
	id SERIAL PRIMARY KEY,
	interaction_type VARCHAR(10) NOT NULL,
	CHECK(interaction_type IN ('Service','Product','Payment','Lead'))
);

CREATE TABLE IF NOT EXISTS stakeholder.interaction_p2 (
	id SERIAL PRIMARY KEY,
	interaction_type VARCHAR(10) NOT NULL,
	CHECK(interaction_type IN ('Give','Receive','Update'))
);

CREATE TABLE IF NOT EXISTS stakeholder.activity_type ( -- Lead can only go with Update, other than that every other combination is possible
	id SERIAL PRIMARY KEY,
	interaction_p1_id INTEGER REFERENCES stakeholder.interaction_p1(id) NOT NULL,
	interaction_p2_id INTEGER REFERENCES stakeholder.interaction_p2(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS stakeholder.activity_log ( -- can one activity log reference another previous activity log with log_id as reference key? For example: reference one 'Receive Payment_Client 1' activity log with 'Give Service_Client 1' activity log.
	id SERIAL PRIMARY KEY,
	activity_type_id INTEGER REFERENCES stakeholder.activity_type(id) NOT NULL,
	stakeholder_id INTEGER REFERENCES stakeholder.record(id) NOT NULL,
	description VARCHAR(200),
	deadline DATE,
	assigned_id INTEGER REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stakeholder.issue ( -- create issue || resolve issue
	id SERIAL PRIMARY KEY,
	has_issue BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update i.e., resolve issue
    created_by_id INTEGER REFERENCES employee.employee(id) NOT NULL,
	description TEXT,
	stakeholder_id INTEGER REFERENCES stakeholder.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS stakeholder.auto_invoice ( -- activate only for recurring - is_active - monthly_subscription || ONE RECORD for each automation
	id SERIAL PRIMARY KEY,
	record_id INTEGER REFERENCES stakeholder.record(id) NOT NULL,
	category_id INTEGER REFERENCES stakeholder.category(id) NOT NULL,
	is_recurring BOOLEAN NOT NULL, -- if recurring put 1, otherwise 0
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	need_invoice BOOLEAN DEFAULT FALSE,
	need_email BOOLEAN DEFAULT FALSE,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS stakeholder.transaction (
	id SERIAL PRIMARY KEY,
	activity_log_id INTEGER REFERENCES stakeholder.activity_log(id) NOT NULL,
	stakeholder_id INTEGER REFERENCES stakeholder.record(id) NOT NULL,
	sapr_id INTEGER REFERENCES stakeholder.auto_invoice(id), -- to check whether automated or not
	month_name VARCHAR(10), -- picks month from calendar || only triggered when is a recurring client
	which_year INT, -- picks year from calendar || only triggered when is a recurring client
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL,
	amount DECIMAL(10,2) NOT NULL, -- if bill_same = true on stakeholder_id then put bill_amount, otherwise accept input
	description TEXT,
	company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS stakeholder.payment_approval(
	id SERIAL PRIMARY KEY,
	payment_log_id INTEGER REFERENCES stakeholder.transaction(id),
	approval BOOLEAN DEFAULT FALSE, -- true = approved
	approved_by_id INTEGER REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS stakeholder.stakeholder_address (
	id SERIAL PRIMARY KEY,
    stakeholder_id INTEGER REFERENCES stakeholder.record(id),
    address_id INTEGER REFERENCES company.address(id) NOT NULL,
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- on update
);