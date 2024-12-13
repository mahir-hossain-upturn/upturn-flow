CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE employee.user ( -- used for AUTHENTICATION & AUTHORIZATION with Supabase
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
    CHECK(marital_status IN('Unmarried','Married','Single'))
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