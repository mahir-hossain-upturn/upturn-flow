CREATE TABLE administration.notice_type (
	nt_id SERIAL PRIMARY KEY,
	type_name VARCHAR(50) NOT NULL,
	CHECK(type_name IN('General Announcement', 'HR Update', 'Administrative Notice', 'Event', 'Policy Update', 'Training/Workshop', 'Others')),
	is_default BOOLEAN DEFAULT FALSE NOT NULL,
	updated_at TIMESTAMP -- on-update
);

CREATE TABLE administration.company_notice (
	cn_id SERIAL PRIMARY KEY,
	notice_type INTEGER REFERENCES administration.notice_type(nt_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.notice_record (
	nr_id SERIAL PRIMARY KEY,
	notice_type INTEGER REFERENCES administration.notice_type(nt_id) NOT NULL, -- need to only give the company specific notice option
	title VARCHAR(200) NOT NULL,
	description TEXT NOT NULL,
	urgency VARCHAR(10) NOT NULL
	CHECK(urgency IN('High','Medium','Low')),
	valid_from DATE NOT NULL,
	valid_till DATE NOT NULL, -- once validity lapses, archive the notice
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.notice_dept ( -- tag the notice to everyone of this dept.
	nd_id SERIAL PRIMARY KEY,
	notice_record INTEGER REFERENCES administration.notice_record(nr_id) NOT NULL,
	department INTEGER REFERENCES company.department(dept_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.notice_unit ( -- tag the notice to everyone of this unit.
	nu_id SERIAL PRIMARY KEY,
	notice_record INTEGER REFERENCES administration.notice_record(nr_id) NOT NULL,
	unit INTEGER REFERENCES company.unit(unit_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.complaint_type (
	ct_id SERIAL PRIMARY KEY,
	complaint_type VARCHAR(25) NOT NULL,
	CHECK(complaint_type IN('Discrimination', 'Bullying', 'Harassment', 'Work Conditions', 'Workplace health & safety', 'Management', 'Work environment', 'Interpersonal Conflicts', 'Retaliation', 'Verbal abuse', 'Workload grievances', 'Workplace violence', 'Others')),
	updated_at TIMESTAMP -- on-update
);

CREATE TABLE administration.company_complaint (
	cc_id SERIAL PRIMARY KEY,
	complaint INTEGER REFERENCES administration.complaint_type(ct_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.compliant_record (
	cr_id SERIAL PRIMARY KEY,
	complaint_type INTEGER REFERENCES administration.complaint_type(ct_id) NOT NULL,
	complainer INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	description TEXT NOT NULL,
	status VARCHAR(10) DEFAULT 'Pending' NOT NULL,
	remark TEXT NOT NULL, -- outcome of the resolution
	CHECK(status IN('Pending','Resolved')),
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.claim_type (
	c_type_id SERIAL PRIMARY KEY,
	claim_items VARCHAR(25) NOT NULL,
	description TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.claim_record (
	c_record_id SERIAL PRIMARY KEY,
	claim_item INTEGER REFERENCES administration.claim_type(c_type_id) NOT NULL,
	event_date DATE NOT NULL, -- date of the event for which you asked for a claim
	amount DECIMAL(10,2) NOT NULL,
	remark VARCHAR(200),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	approval BOOLEAN DEFAULT FALSE,
	approved_by INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	claimant INTEGER REFERENCES employee.employee(employee_id) NOT NULL, -- store id instead of name, though the claimant inputs his/her name
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.requisition_type (
	r_type_id SERIAL PRIMARY KEY,
	requisition_item VARCHAR(50) NOT NULL,
	description TEXT,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.requisition_inventory (
	ri_id SERIAL PRIMARY KEY,
	requisition_item INTEGER REFERENCES administration.requisition_type(r_type_id),
	current_balance INT NOT NULL, --quantity of the item left
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP, -- gets updated when someone takes, deposits or is lost, damaged, depreciated
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.requisition_record (
	rr_id SERIAL PRIMARY KEY,
	requisition_item INTEGER REFERENCES administration.requisition_type(r_type_id) NOT NULL,
	employee INTEGER REFERENCES employee.employee(employee_id) NOT NULL, -- can be IT-user for discarding or employee-user for acquiring
	quantity INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	is_approved BOOLEAN DEFAULT TRUE, -- true = approved, false = not approved || if approved, subtract quantity from current_balance
	is_discarded BOOLEAN DEFAULT TRUE, -- if true then subtract quantity from current_balance (lost, damaged, depreciated)
	is_added BOOLEAN DEFAULT TRUE,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);
