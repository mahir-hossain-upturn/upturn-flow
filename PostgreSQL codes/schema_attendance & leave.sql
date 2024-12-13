CREATE TABLE attendance.site (
    site_id SERIAL PRIMARY KEY,
    site_name VARCHAR(100) NOT NULL,
    coordinates POINT NOT NULL,
    check_in TIMESTAMP NOT NULL,
    check_out TIMESTAMP NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE attendance.record (
    r_id SERIAL PRIMARY KEY,
    attendance_date DATE DEFAULT CURRENT_DATE NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
    site INTEGER REFERENCES attendance.site(site_id),
    checkin_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	checkin_coordinates POINT NOT NULL,
    checkin_location POINT NOT NULL, -- input map url
    checkout_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- if not entered by 12am. of that day, record 12:00am
	checkout_coordinates POINT NOT NULL,
    checkout_location POINT NOT NULL, -- input map url
	employee_id INTEGER REFERENCES employee.employee(employee_id)
);

CREATE TABLE attendance.leave_calendar ( -- iOS calendar as UI
	lc_id SERIAL PRIMARY KEY,
	annual_holiday DATE NOT NULL,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP DEFAULT NOW(),
	company_id INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE attendance.weekly_holiday_config ( -- assuming Saturday = 1, thus Friday = 7
	config_id SERIAL PRIMARY KEY,
	start_day SMALLINT NOT NULL,
	end_day SMALLINT NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE attendance.leave_type (
	type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(30) NOT NULL,
	annual_quota SMALLINT NOT NULL,
    company_id INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE attendance.leave_request ( -- checks if the leave balance <= 0. If yes, gives warning, otherwise request goes through
	lr_id SERIAL PRIMARY KEY,
	leave_type INTEGER REFERENCES attendance.leave_type(type_id) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	remarks VARCHAR(250),
	status VARCHAR(10) DEFAULT 'Pending' NOT NULL,
	CHECK (status IN ('Pending', 'Accepted', 'Rejected')),
	employee_id INTEGER REFERENCES employee.employee(employee_id),
	company_id INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE attendance.leave_balance (
	lb_id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id),
	type_id INTEGER REFERENCES attendance.leave_type(type_id) NOT NULL,
	leave_balance SMALLINT NOT NULL -- is updated everytime a leave is accepted
);

CREATE TABLE attendance.leave_record ( -- records only when leave is accepted
	lr_id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	type_id INTEGER REFERENCES attendance.leave_type(type_id) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	duration SMALLINT NOT NULL, -- (end_date - start_date)
	approved_by INTEGER REFERENCES employee.supervisor(supervisor_id) NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE attendance.status ( -- to return the attendance status, at first check attendance_record, is yes ('PRESENT' / 'LATE'), if no, check leave_calendar for holiday (no record for holiday and weekends), then check leave_record for accepted leave (if yes, 'On Leave'), if no, 'Absent'
	s_id SERIAL PRIMARY KEY,
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'WRONG_LOCATION')),
	employee_id INTEGER REFERENCES employee.employee(employee_id),
	company_id INTEGER REFERENCES company.company(company_id) NOT NULL
);