CREATE TABLE stakeholder.type (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CHECK (type_name IN ('Client', 'Supplier', 'Lead', 'Vendor'))
);

CREATE TABLE stakeholder.category (
	category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL,
    CHECK (category_name IN ('Prospective','One-time','Recurring','On-Hold','Discontinued'))
);

CREATE TABLE stakeholder.record (
	stakeholder_id SERIAL PRIMARY KEY,
    stakeholder_type INTEGER REFERENCES stakeholder.type(type_id) NOT NULL,
    category INTEGER REFERENCES stakeholder.category(category_id) NOT NULL,
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
    company_id INTEGER REFERENCES company.company(company_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL -- ON UPDATE
);

CREATE TABLE stakeholder.interaction_p1 (
	ip1_id SERIAL PRIMARY KEY,
	interaction_type VARCHAR(10) NOT NULL,
	CHECK(interaction_type IN ('Service','Product','Payment','Lead'))
);

CREATE TABLE stakeholder.interaction_p2 (
	ip2_id SERIAL PRIMARY KEY,
	interaction_type VARCHAR(10) NOT NULL,
	CHECK(interaction_type IN ('Give','Receive','Update'))
);

CREATE TABLE stakeholder.activity_type ( -- Lead can only go with Update, other than that every other combination is possible
	activity_type_id SERIAL PRIMARY KEY,
	interaction_p1 INTEGER REFERENCES stakeholder.interaction_p1(ip1_id) NOT NULL,
	interaction_p2 INTEGER REFERENCES stakeholder.interaction_p2(ip2_id) NOT NULL
);

CREATE TABLE stakeholder.activity_log ( -- can one activity log reference another previous activity log with log_id as reference key? For example: reference one 'Receive Payment_Client 1' activity log with 'Give Service_Client 1' activity log.
	log_id SERIAL PRIMARY KEY,
	activity_type INTEGER REFERENCES stakeholder.activity_type(activity_type_id) NOT NULL,
	stakeholder INTEGER REFERENCES stakeholder.record(stakeholder_id) NOT NULL,
	description VARCHAR(200),
	deadline DATE,
	assigned INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP
);

CREATE TABLE stakeholder.issue ( -- create issue || resolve issue
	si_id SERIAL PRIMARY KEY,
	has_issue BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update i.e., resolve issue
    created_by INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	description TEXT,
	stakeholder INTEGER REFERENCES stakeholder.record(stakeholder_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE stakeholder.auto_invoice ( -- activate only for recurring - is_active - monthly_subscription || ONE RECORD for each automation
	sai_id SERIAL PRIMARY KEY,
	stakeholder INTEGER REFERENCES stakeholder.record(stakeholder_id) NOT NULL,
	stakeholder INTEGER REFERENCES stakeholder.category(category_id) NOT NULL,
	is_recurring BOOLEAN NOT NULL, -- if recurring put 1, otherwise 0
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	need_invoice BOOLEAN DEFAULT FALSE,
	need_email BOOLEAN DEFAULT FALSE,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE stakeholder.transaction (
	st_id SERIAL PRIMARY KEY,
	activity_log INTEGER REFERENCES stakeholder.activity_log(log_id) NOT NULL,
	stakeholder INTEGER REFERENCES stakeholder.record(stakeholder_id) NOT NULL,
	sapr_id INTEGER REFERENCES stakeholder.auto_invoice(sai_id), -- to check whether automated or not
	month_name VARCHAR(10), -- picks month from calendar || only triggered when is a recurring client
	which_year INT, -- picks year from calendar || only triggered when is a recurring client
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL,
	amount DECIMAL(10,2) NOT NULL, -- if bill_same = true on stakeholder_id then put bill_amount, otherwise accept input
	description TEXT,
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE stakeholder.payment_approval(
	p_approval_id SERIAL PRIMARY KEY,
	payment_log INTEGER REFERENCES stakeholder.transaction(st_id),
	approval BOOLEAN DEFAULT FALSE, -- true = approved
	approved_by INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE stakeholder.stakeholder_address (
	ssa_id SERIAL PRIMARY KEY,
    stakeholder INTEGER REFERENCES stakeholder.record(stakeholder_id),
    address_id INTEGER REFERENCES company.address(address_id) NOT NULL,
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- on update
);