CREATE TABLE IF NOT EXISTS employee.employee_designation (
    id SERIAL PRIMARY KEY,
	employee_id uuid REFERENCES employee.employee(id) NOT NULL,
    designation_id INTEGER REFERENCES company.designation(id), -- div, dept, unit & position can be traced with Join
    start_date DATE NOT NULL, -- position start date
    end_date DATE, -- position end date
    is_current BOOLEAN DEFAULT true, -- (to store all positions changes)
    approved_by_id uuid REFERENCES employee.employee(id), -- (approval required before changing position in the system)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS employee.employee_address (
	id SERIAL PRIMARY KEY,
    employee_id uuid REFERENCES employee.employee(id),
    -- ! THIS NEEDS ATTENTION
    address_id INTEGER REFERENCES company.address(id) NOT NULL,
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS employee.personal_info (
    id uuid REFERENCES employee.employee(id) PRIMARY KEY,
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
    company_id INTEGER NOT NULL REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS employee.qualification_type ( -- for the time being, just create the table and not link it with anything else
id SERIAL PRIMARY KEY,
name VARCHAR(10) UNIQUE NOT NULL,
CHECK(name IN('Training','Specialization','Schooling','Project','Publication'))
);

CREATE TABLE IF NOT EXISTS employee.schooling (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL, -- provide drop-down from front-end
    CHECK(degree_type IN('High School','College','Diploma','Bachelors','Masters','PGD','PhD','Post-Doc')),
    name VARCHAR(50) NOT NULL,
    institute VARCHAR(100) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    result VARCHAR(15) NOT NULL, -- GPA / CGPA / Division
    employee_id uuid NOT NULL REFERENCES employee.employee(id),
    company_id INTEGER NOT NULL REFERENCES company.company(id)
);

CREATE TABLE IF NOT EXISTS employee.experience (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(50) NOT NULL,
    designation VARCHAR(25) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    description TEXT,
    employee_id uuid REFERENCES employee.employee(id),
    company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS employee.supervisor ( -- assigning who are supervisors
	id uuid REFERENCES employee.employee(id) NOT NULL PRIMARY KEY,
	is_supervisor BOOLEAN DEFAULT TRUE NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS employee.supervisor_employee ( -- assigning employees to supervisors
	id SERIAL PRIMARY KEY,
	supervisor_id uuid REFERENCES employee.supervisor(id) NOT NULL,
	employee_id uuid REFERENCES employee.employee(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);