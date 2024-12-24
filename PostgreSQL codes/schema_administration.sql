CREATE TABLE IF NOT EXISTS administration.notice_type (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	CHECK(name IN('General Announcement', 'HR Update', 'Administrative Notice', 'Event', 'Policy Update', 'Training/Workshop', 'Others')),
	is_default BOOLEAN DEFAULT FALSE NOT NULL,
	updated_at TIMESTAMP -- on-update
);

CREATE TABLE IF NOT EXISTS administration.company_notice (
	id SERIAL PRIMARY KEY,
	notice_type INTEGER REFERENCES administration.notice_type(id) NOT NULL,
	company INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.notice_record (
	id SERIAL PRIMARY KEY,
	notice_type_id INTEGER REFERENCES administration.notice_type(id) NOT NULL, -- need to only give the company specific notice option
	title VARCHAR(200) NOT NULL,
	description TEXT NOT NULL,
	urgency VARCHAR(10) NOT NULL
	CHECK(urgency IN('High','Medium','Low')),
	valid_from DATE NOT NULL,
	valid_till DATE NOT NULL, -- once validity lapses, archive the notice
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.notice_dept ( -- tag the notice to everyone of this dept.
	nd_id SERIAL PRIMARY KEY,
	notice_record_id INTEGER REFERENCES administration.notice_record(id) NOT NULL,
	department_id INTEGER REFERENCES company.dept(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.notice_unit ( -- tag the notice to everyone of this unit.
	id SERIAL PRIMARY KEY,
	notice_record_id INTEGER REFERENCES administration.notice_record(id) NOT NULL,
	unit_id INTEGER REFERENCES company.unit(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.complaint_type (
	id SERIAL PRIMARY KEY,
	type VARCHAR(25) NOT NULL,
	CHECK(type IN('Discrimination', 'Bullying', 'Harassment', 'Work Conditions', 'Workplace health & safety', 'Management', 'Work environment', 'Interpersonal Conflicts', 'Retaliation', 'Verbal abuse', 'Workload grievances', 'Workplace violence', 'Others')),
	updated_at TIMESTAMP -- on-update
);

CREATE TABLE IF NOT EXISTS administration.company_complaint (
	id SERIAL PRIMARY KEY,
	complaint_type_id INTEGER REFERENCES administration.complaint_type(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.compliant_record (
	id SERIAL PRIMARY KEY,
	complaint_type_id INTEGER REFERENCES administration.complaint_type(id) NOT NULL,
	complainer_id INTEGER REFERENCES employee.employee(id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	description TEXT NOT NULL,
	status VARCHAR(10) DEFAULT 'Pending' NOT NULL,
	remark TEXT NOT NULL, -- outcome of the resolution
	CHECK(status IN('Pending','Resolved')),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.claim_type (
	id SERIAL PRIMARY KEY,
	claim_items VARCHAR(25) NOT NULL,
	description TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.claim_record (
	id SERIAL PRIMARY KEY,
	claim_type_id INTEGER REFERENCES administration.claim_type(id) NOT NULL,
	event_date DATE NOT NULL, -- date of the event for which you asked for a claim
	amount DECIMAL(10,2) NOT NULL,
	remark VARCHAR(200),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	approval BOOLEAN DEFAULT FALSE,
	approved_by_id INTEGER REFERENCES employee.employee(id) NOT NULL,
	claimant_id INTEGER REFERENCES employee.employee(id) NOT NULL, -- store id instead of name, though the claimant inputs his/her name
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.requisition_type (
	id SERIAL PRIMARY KEY,
	requisition_item VARCHAR(50) NOT NULL,
	description TEXT,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.requisition_inventory (
	id SERIAL PRIMARY KEY,
	requisition_item INTEGER REFERENCES administration.requisition_type(id),
	current_balance INT NOT NULL, --quantity of the item left
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP, -- gets updated when someone takes, deposits or is lost, damaged, depreciated
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS administration.requisition_record (
	id SERIAL PRIMARY KEY,
	requisition_type_id INTEGER REFERENCES administration.requisition_type(id) NOT NULL,
	employee_id INTEGER REFERENCES employee.employee(id) NOT NULL, -- can be IT-user for discarding or employee-user for acquiring
	quantity INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	is_approved BOOLEAN DEFAULT TRUE, -- true = approved, false = not approved || if approved, subtract quantity from current_balance
	is_discarded BOOLEAN DEFAULT TRUE, -- if true then subtract quantity from current_balance (lost, damaged, depreciated)
	is_added BOOLEAN DEFAULT TRUE,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);
