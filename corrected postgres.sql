CREATE SCHEMA company;
CREATE SCHEMA administration;
CREATE SCHEMA employee;
CREATE SCHEMA attendance;
CREATE SCHEMA payroll;
CREATE SCHEMA performance;
CREATE SCHEMA project;
CREATE SCHEMA stakeholder;
CREATE SCHEMA "transaction";

-- Schema: Company
CREATE TABLE company.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL
);

CREATE TABLE company.industry (
    industry_id SERIAL PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL, -- did input for all the possible industry for data validation
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.country_industry ( -- this table works as the input field for country & industry when a company registers
ci_id SERIAL PRIMARY KEY,
country INTEGER REFERENCES company.country(country_id) NOT NULL,
industry INTEGER REFERENCES company.industry(industry_id) NOT NULL
);

CREATE TABLE company.company (
company_id SERIAL PRIMARY KEY NOT NULL,
company_name VARCHAR(100) NOT NULL,
company_code VARCHAR(50) UNIQUE NOT NULL, -- data validation required to ask for more than 8 characters, 1 uc, 1lc, 1 special
country_industry INTEGER REFERENCES company.country_industry(ci_id) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL -- at update
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE employee.user (
    user_id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT FALSE NOT NULL, -- every session lasts for 60 minutes. If no activity for 60 minutes, the account logs out automatically. Account is only active if the tab / app is open last & last activity < 60 mins ago.
    last_login TIMESTAMP NOT  NULL, -- is used to count session duration
    has_approval BOOLEAN DEFAULT FALSE NOT NULL -- (to start/stop user usage)
);

CREATE TABLE employee.employee (
    employee_id SERIAL PRIMARY KEY,
	company_id INTEGER REFERENCES company.company(company_id) NOT NULL,
    employee_id_input VARCHAR(20), -- MIR1238 indicates a specific employee || search functionality can be applied to this.
	user_id uuid REFERENCES employee.user(user_id) UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

ALTER TABLE employee.user 
ADD COLUMN employee_id INTEGER REFERENCES employee.employee(employee_id) UNIQUE;

CREATE TABLE company.currency (
    currency_code VARCHAR(3) PRIMARY KEY,
	currency_name VARCHAR(25) NOT NULL
);

CREATE TABLE company.division (
    div_id SERIAL PRIMARY KEY,
    div_name VARCHAR(50) NOT NULL,
    div_head INTEGER REFERENCES employee.employee(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL, -- at update
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE company.dept (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    dept_head INTEGER REFERENCES employee.employee(employee_id),
    dept_description TEXT, -- input the JD here || create a rich text dialog box
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.unit (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(50) NOT NULL,
    unit_head INTEGER REFERENCES employee.employee(employee_id),
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.position (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL,
    position_jd TEXT,
    position_grade VARCHAR(10),
    salary_range_min DECIMAL(10,2),
    salary_range_max DECIMAL(10,2),
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.designation (
    desig_id SERIAL PRIMARY KEY,
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    division INTEGER REFERENCES company.division(div_id),
    dept INTEGER REFERENCES company.dept(dept_id),
    unit INTEGER REFERENCES company.unit(unit_id),
    position INTEGER REFERENCES company.position(position_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    CHECK(role_name IN('Super Admin','Admin','HR','Supervisor','End User')),
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    employee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);


CREATE TABLE company.address ( 
    address_id SERIAL PRIMARY KEY,
    address_type VARCHAR(20) NOT NULL,
    CHECK(address_type IN('Employee','Client','Supplier','Vendor','Lead')),
    street_address VARCHAR(100) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state VARCHAR(20),
    postal_code VARCHAR(10),
    country INTEGER REFERENCES company.country(country_id) NOT NULL,
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);


-- Schema: Employee
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE employee.employee_designation (
    ep_id SERIAL PRIMARY KEY,
	employee_id INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
    designation INTEGER REFERENCES company.designation(desig_id), -- div, dept, unit & position can be traced with Join
    start_date DATE NOT NULL, -- position start date
    end_date DATE, -- position end date
    is_current BOOLEAN DEFAULT true, -- (to store all positions changes)
    approved_by INTEGER REFERENCES employee.employee(employee_id), -- (approval required before changing position in the system)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE employee.employee_address (
	eea_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employee.employee(employee_id),
    address_id INTEGER REFERENCES company.address(address_id) NOT NULL,
    company INTEGER REFERENCES company.company(company_id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE employee.personal_info (
    employee_id INTEGER REFERENCES employee.employee(employee_id) PRIMARY KEY,
    date_of_birth DATE,
    gender VARCHAR(10), -- provide drop-down from front-end
    CHECK(gender IN('Male','Female','Other')),
    blood_group VARCHAR(3), -- provide drop-down from front-end
    CHECK(blood_group IN('A+','B+','O+','AB+','A-','B-','AB-','O-')),
    marital_status VARCHAR(20), -- provide drop-down from front-end
    CHECK(marital_status IN('Unmarried','Married','Single')),
    nid_no VARCHAR(25) UNIQUE,
    religion VARCHAR(10), 
	father_name VARCHAR(50),
	mother_name VARCHAR(50),
	spouse_name VARCHAR(50),
    emergency_contact_name VARCHAR(50), -- put a tick mark beside the father / mother / spouse box, if chosen contact_name and relation not required, otherwise take input (can be of a friend)
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(15), -- can be brother, friend
    company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE employee.qualification_type ( -- for the time being, just create the table and not link it with anything else
eet_id SERIAL PRIMARY KEY,
type_name VARCHAR(10) NOT NULL,
CHECK(type_name IN('Training','Specialization','Schooling','Project','Publication'))
);

CREATE TABLE employee.schooling (
    edu_id SERIAL PRIMARY KEY,
    degree_type VARCHAR(50) NOT NULL, -- provide drop-down from front-end
    CHECK(degree_type IN('High School','College','Diploma','Bachelors','Masters','PGD','PhD','Post-Doc')),
    degree_name VARCHAR(50) NOT NULL,
    institute VARCHAR(100) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    result VARCHAR(15) NOT NULL, -- GPA / CGPA / Division
    employee_id INTEGER REFERENCES employee.employee(employee_id),
    company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE employee.experience (
    exp_id SERIAL PRIMARY KEY,
    company_name VARCHAR(50) NOT NULL,
    designation VARCHAR(25) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    description TEXT,
    employee_id INTEGER REFERENCES employee.employee(employee_id),
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE employee.supervisor ( -- assigning who are supervisors
	supervisor_id SERIAL PRIMARY KEY,
	supervisor INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	is_supervisor BOOLEAN DEFAULT TRUE NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE employee.supervisor_employee ( -- assigning employees to supervisors
	es_id SERIAL PRIMARY KEY,
	supervisor_id INTEGER REFERENCES employee.supervisor(supervisor_id) NOT NULL,
	employee_id INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	company_id INTEGER REFERENCES company.company(company_id) NOT NULL
);



-- Schema: Attendance & Leave
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


-- Schema: Project Management
CREATE TABLE project.project_record (
    project_id SERIAL PRIMARY KEY,
    project_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	project_lead INTEGER REFERENCES employee.employee(employee_id),
	remark TEXT, -- project conclusion / closing remark
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_status (
	pstatus_id SERIAL PRIMARY KEY,
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'ARCHIEVED')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_dept (
	pdept_id SERIAL PRIMARY KEY,
	project INTEGER REFERENCES project.project_record(project_id),
	department INTEGER REFERENCES company.dept(dept_id)
);

CREATE TABLE project.project_progression (
	p_progress_id SERIAL PRIMARY KEY,
	progress DECIMAL(3,2) NOT NULL, -- =(milestone_progression / no. of milestone * 100)
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_outcome (
	p_outcome_id SERIAL PRIMARY KEY,
	p_outcome VARCHAR(200) NOT NULL,
	p_result VARCHAR(20) NOT NULL,
	CHECK (p_result IN ('NOT_ACHIEVED', 'ACHIEVED')), -- not null after project == completed
	achievement DECIMAL(3,2) NOT NULL, -- default value assignment. Can be changed.
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

ALTER TABLE project.project_record
ADD COLUMN status INTEGER REFERENCES project.project_status (pstatus_id);

ALTER TABLE project.project_record
ADD COLUMN progress INTEGER REFERENCES project.project_progression(p_progress_id);

ALTER TABLE project.project_record
ADD COLUMN outcome INTEGER REFERENCES project.project_outcome(p_outcome_id);

CREATE TABLE project.milestone_record (
	milestone_id SERIAL PRIMARY KEY,
	milestone_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL, -- is determined by the earliest start date of a task under this milestone
    end_date DATE NOT NULL, -- is determined by the end date of the latest task under this milestone
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED')), -- (if a task has been created and assigned == 'In_Progress', otherwise == 'Not_Started') (if sum of task progression = 100, 'Completed', otherwise, 'In-Progress')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_assignment (
	ma_id SERIAL PRIMARY KEY,
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	assignee INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_comment (
	mc_id SERIAL PRIMARY KEY,
	mcomment TEXT,
	commentor INTEGER REFERENCES employee.employee(employee_id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- comments can be edited for 1st 30 mins
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_progression (
	mp_id SERIAL PRIMARY KEY,
	progress DECIMAL(3,2) NOT NULL, -- (== no. of task completed / total no. of tasks in this milestone)
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

ALTER TABLE project.project_dept
ADD COLUMN company INTEGER REFERENCES company.company(company_id);

CREATE TABLE project.task_record (
	task_id SERIAL PRIMARY KEY,
	task_title VARCHAR(200) NOT NULL,
	task_description TEXT,
	start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	status BOOLEAN DEFAULT FALSE NOT NULL, -- False = Not Done, True = Done
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.task_assignment (
	ta_id SERIAL PRIMARY KEY,
	task INTEGER REFERENCES project.task_record(task_id),
	assignee INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.task_update (
	tu_id SERIAL PRIMARY KEY,
	task INTEGER REFERENCES project.task_record(task_id),
	has_issue BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
    created_by INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

-- Schema: Stakeholder Management
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




-- Schema: Transaction
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

-- Schema: Payroll Management
CREATE TABLE payroll.salary_component ( -- this assumes that fixed and gross components remain the same for all employees in the company
	psc_id SERIAL PRIMARY KEY,
	component_name VARCHAR(50) NOT NULL, -- verify with Income Tax Manual
	CHECK(component_name IN('Basic Salary','Home Rent Allowance','Festival Bonus','Car Maintenance Allowance','Mobile Bill','Entertainment Allowance','Convenyance Allowance','Overtime Pay','Lunch Subsidy','Employee contribution to PF')),
	is_fixed BOOLEAN DEFAULT TRUE, -- if not fixed, then variable
	description TEXT,
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE payroll.employee_f_salary (
	pefs_id SERIAL PRIMARY KEY,
	employee INTEGER REFERENCES employee.employee(employee_id),
	salary_component INTEGER REFERENCES payroll.salary_component(psc_id),
	effective_from DATE NOT NULL,
	effective_till DATE,
	amount DECIMAL(10,2) NOT NULL,
	is_active BOOLEAN DEFAULT TRUE NOT NULL, -- this component hits / impacts the payslip of the employee 
	is_current BOOLEAN DEFAULT TRUE, -- current means will be paid now; later means to be paid later like Provident Fund 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP, -- on update
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE payroll.employee_v_salary (
	pevs_id SERIAL PRIMARY KEY,
	employee INTEGER REFERENCES employee.employee(employee_id),
	salary_component INTEGER REFERENCES payroll.salary_component(psc_id),
	amount DECIMAL(10,2) NOT NULL,
	payment_month DATE NOT NULL, -- record the month on which it is going to be hit the payslip
	is_current BOOLEAN DEFAULT TRUE, -- some portion of variable pay can be held back like Profit Share, this gets accumulated over the years
	remark VARCHAR(200), -- write down the occasion like Profit Share, Festival Bonus, Commission
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE payroll.employee_salary_record (
	pesr_id SERIAL PRIMARY KEY,
	employee INTEGER REFERENCES employee.employee(employee_id),
	which_month DATE NOT NULL, -- format the month from front-end UI
	which_year DATE NOT NULL, -- format the year from front-end UI
	gross_salary INT NOT NULL, -- Gross Salary = f_salary (c+l) + v_salary (c+l)
	tds INT NOT NULL, -- Tax Deductible at source
	net_salary INT NOT NULL, -- Net Payable Salary / Net Receipt this month = f_salary(c) + v_salary(c) - TDS
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- auto generated by the last week of the month
	updated_at TIMESTAMP,
	approved_by INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE payroll.disbursement (
	pd_id SERIAL PRIMARY KEY,
	employee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	salary_record INTEGER REFERENCES payroll.employee_salary_record(pesr_id) NOT NULL,
	is_disbursed BOOLEAN DEFAULT TRUE NOT NULL,
	transaction_date DATE NOT NULL,
	payment_method INTEGER REFERENCES transaction.payment_method(pm_id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE payroll.salary_accumulation ( -- if is_current = FALSE (Fixed + Variable), the amount gets accumulated over the years || Automatically creates a record when f & v (l) becomes due
	psa_id SERIAL PRIMARY KEY,
	variable_salary INTEGER REFERENCES payroll.employee_v_salary(pevs_id) NOT NULL,
	fixed_salalry INTEGER REFERENCES payroll.employee_f_salary(pefs_id) NOT NULL,
	net_balance INT NOT NULL, -- accumulation of f_salary(l) & v_salary(l) till date
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	employee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);



-- Schema: Administrative Management
CREATE TABLE administration.notice_type (
	nt_id SERIAL PRIMARY KEY,
	type_name VARCHAR(50) NOT NULL,
	CHECK(type_name IN('General Announcement', 'HR Update', 'Administrative Notice', 'Event', 'Policy Update', 'Training/Workshop','Others')),
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
	notice_type INTEGER REFERENCES administration.notice_type(nt_id) NOT NULL,
	title VARCHAR(200) NOT NULL,
	description TEXT NOT NULL,
	urgency VARCHAR(10) NOT NULL
	CHECK(urgency IN('High','Medium','Low')),
	valid_from DATE NOT NULL,
	valid_till DATE NOT NULL, -- once validity lapses archieve the notice
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE administration.notice_dept ( -- tag the notice to everyone of this dept.
	nd_id SERIAL PRIMARY KEY,
	notice_record INTEGER REFERENCES administration.notice_record(nr_id) NOT NULL,
	department INTEGER REFERENCES company.dept(dept_id) NOT NULL,
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
	status VARCHAR(10) NOT NULL,
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
	employee INTEGER REFERENCES employee.employee(employee_id) NOT NULL, -- can be IT for discarding or employee for acquiring
	quantity INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	is_given BOOLEAN DEFAULT TRUE, -- true = given, false = not given || if given, subtract quantity from current_balance
	is_discarded BOOLEAN DEFAULT TRUE, -- if true then subtract quantity from current_balance (lost, damaged, depreciated)
	is_added BOOLEAN DEFAULT TRUE,
	company INTEGER REFERENCES company.company(company_id) NOT NULL
);



-- Schema: Performance Management
CREATE TABLE performance.evaluation_type (
	pet_id SERIAL PRIMARY KEY,
	evaluation_type VARCHAR(50) NOT NULL,
	CHECK(evaluation_type IN('Supervisor Feedback','Peer-to-peer Feedback','Project-based Feedback')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE performance.evaluation_metric (
	pem_id SERIAL PRIMARY KEY,
	metric VARCHAR(50) NOT NULL,
	CHECK(metric IN('Job Knowledge and Expertise','Quality of Work','Productivity and Efficiency','Communication Skills','Problem-Solving and Innovation','Teamwork and Collaboration','Adaptability and Flexibility','Reliability and Accountability','Goal Completion','Commitment to Growth and Learning'))
);

CREATE TABLE performance.supervisor_rating ( -- when 'Supervisor Feedback' is chosen || only possible when HR opens the portal
	psr_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.supervisor(supervisor_id) NOT NULL, -- check whether supervisor or not
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	job_knowledge_and_expertise SMALLINT NOT NULL, -- from 1 to 5
	quality_of_work SMALLINT NOT NULL, -- from 1 to 5
	productivity_and_efficiency SMALLINT NOT NULL, -- from 1 to 5
	communication_skills SMALLINT NOT NULL, -- from 1 to 5
	problem_solving_and_innovation SMALLINT NOT NULL, -- from 1 to 5
	teamwork_and_collaboration SMALLINT NOT NULL, -- from 1 to 5
	adaptability_and_flexibility SMALLINT NOT NULL, -- from 1 to 5
	reliability_and_accountability SMALLINT NOT NULL, -- from 1 to 5
	goal_completion SMALLINT NOT NULL, -- from 1 to 5
	commitment_to_growth_and_learning SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);

CREATE TABLE performance.peer_rating ( -- when 'Peer-to-peer Feedback' is chosen || only possible when HR opens the portal
	peer_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	teamwork_and_cooperation SMALLINT NOT NULL, -- from 1 to 5
	communication_effectiveness SMALLINT NOT NULL, -- from 1 to 5
	conflict_resolution SMALLINT NOT NULL, -- from 1 to 5
	active_listening SMALLINT NOT NULL, -- from 1 to 5
	supportiveness SMALLINT NOT NULL, -- from 1 to 5
	respect_and_professionalism SMALLINT NOT NULL, -- from 1 to 5
	trustworthiness SMALLINT NOT NULL, -- from 1 to 5
	adaptability_in_team_dynamics SMALLINT NOT NULL, -- from 1 to 5
	workload_balance_contribution SMALLINT NOT NULL, -- from 1 to 5
	peer_mentorship SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);

CREATE TABLE performance.project_rating ( -- when 'Project Feedback' is chosen || only possible when HR opens the portal
	ppr_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	project INTEGER REFERENCES project.project_record(project_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	task_completion_efficiency SMALLINT NOT NULL, -- from 1 to 5
	quality_of_deliverables SMALLINT NOT NULL, -- from 1 to 5
	responsiveness SMALLINT NOT NULL, -- from 1 to 5
	initiave_in_problem_solving SMALLINT NOT NULL, -- from 1 to 5
	goal_alignment SMALLINT NOT NULL, -- from 1 to 5
	team_contribution SMALLINT NOT NULL, -- from 1 to 5
	collaboration_with_team_members SMALLINT NOT NULL, -- from 1 to 5
	adaptability_under_pressure SMALLINT NOT NULL, -- from 1 to 5
	accountability SMALLINT NOT NULL, -- from 1 to 5
	work_ethic SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);
