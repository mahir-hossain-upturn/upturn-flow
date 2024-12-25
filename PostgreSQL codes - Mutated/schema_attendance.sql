CREATE TABLE IF NOT EXISTS attendance.site (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    coordinates POINT NOT NULL,
    check_in TIMESTAMP NOT NULL,
    check_out TIMESTAMP NOT NULL,
	company_id INTEGER REFERENCES company.company(id)
    location TEXT NOT NULL, -- input map url
);

CREATE TABLE IF NOT EXISTS attendance.record (
    id SERIAL PRIMARY KEY,
    attendance_date DATE DEFAULT CURRENT_DATE NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
    site_id INTEGER REFERENCES attendance.site(id),
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	check_in_coordinates POINT NOT NULL,
    check_out_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- if not entered by 12am. of that day, record 12:00am
	check_out_coordinates POINT NOT NULL,
	employee_id uuid REFERENCES employee.employee(id)
);

CREATE TABLE IF NOT EXISTS attendance.leave_calendar ( -- iOS calendar as UI
	id SERIAL PRIMARY KEY,
	annual_holiday DATE NOT NULL,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP DEFAULT NOW(),
	company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS attendance.weekly_holiday_config ( -- assuming Saturday = 1, thus Friday = 7
	id SERIAL PRIMARY KEY,
	start_day SMALLINT NOT NULL,
	end_day SMALLINT NOT NULL,
	company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS attendance.leave_type (
	id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
	annual_quota SMALLINT NOT NULL,
    company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS attendance.leave_record ( -- checks if the leave balance <= 0. If yes, gives warning, otherwise request goes through
	id SERIAL PRIMARY KEY,
	type_id INTEGER REFERENCES attendance.leave_type(id) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	remarks VARCHAR(250),
	status VARCHAR(10) DEFAULT 'Pending' NOT NULL,
	CHECK (status IN ('Pending', 'Accepted', 'Rejected')),
	approved_by_id INTEGER REFERENCES employee.supervisor(id),
	employee_id uuid REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS attendance.leave_balance (
	id SERIAL PRIMARY KEY,
	employee_id uuid REFERENCES employee.employee(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id),
	type_id INTEGER REFERENCES attendance.leave_type(id) NOT NULL,
	leave_balance SMALLINT NOT NULL -- is updated everytime a leave is accepted
);

-- CREATE TABLE IF NOT EXISTS attendance.leave_record ( -- records only when leave is accepted
-- 	id SERIAL PRIMARY KEY,
-- 	employee_id uuid REFERENCES employee.employee(id) NOT NULL,
-- 	type_id INTEGER REFERENCES attendance.leave_type(id) NOT NULL,
-- 	start_date DATE NOT NULL,
-- 	end_date DATE NOT NULL,
-- 	duration SMALLINT NOT NULL, -- (end_date - start_date)
-- 	approved_by_id INTEGER REFERENCES employee.supervisor(id) NOT NULL,
-- 	company_id INTEGER REFERENCES company.company(id) NOT NULL
-- );

CREATE TABLE IF NOT EXISTS attendance.status ( -- to return the attendance status, at first check attendance_record, is yes ('PRESENT' / 'LATE'), if no, check leave_calendar for holiday (no record for holiday and weekends), then check leave_record for accepted leave (if yes, 'On Leave'), if no, 'Absent'
	id SERIAL PRIMARY KEY,
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'WRONG_LOCATION')),
	employee_id uuid REFERENCES employee.employee(id),
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);