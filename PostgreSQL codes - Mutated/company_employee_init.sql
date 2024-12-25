
CREATE TABLE IF NOT EXISTS company.country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL -- did input for all the possible countries for data validation
);

CREATE TABLE IF NOT EXISTS company.industry (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL -- did input for all the possible industries for data validation
);

CREATE TABLE IF NOT EXISTS company.company (
id SERIAL PRIMARY KEY NOT NULL,
name VARCHAR(100) NOT NULL,
code VARCHAR(50) UNIQUE NOT NULL, -- data validation required to ask for more than 8 characters, 1 uc, 1lc, 1 special
country VARCHAR(50) REFERENCES company.country(name) NOT NULL,
industry VARCHAR(100) REFERENCES company.industry(name) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL -- at update
);

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA employee;

CREATE TABLE IF NOT EXISTS employee.user ( -- used for AUTHENTICATION & AUTHORIZATION with Supabase
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    last_login TIMESTAMP NOT  NULL -- is used to count session duration
);

CREATE TABLE IF NOT EXISTS employee.employee (
    id uuid PRIMARY KEY REFERENCES employee.user(id),
	-- username VARCHAR(50) UNIQUE NOT NULL,
    has_approval VARCHAR(8) DEFAULT 'PENDING' NOT NULL -- (to start/stop user usage)
    CHECK(has_approval IN('ACCEPTED','REJECTED', 'PENDING')), -- PENDING is for new users
    is_active BOOLEAN DEFAULT FALSE NOT NULL, -- every session lasts for 60 minutes. If no activity for 60 minutes, the account logs out automatically. Account is only active if the tab / app is open last & last activity < 60 mins ago.
    email VARCHAR(100) UNIQUE NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
    employee_id_input VARCHAR(20), -- MIR1238 indicates a specific employee || search functionality can be applied to this.
	user_id uuid REFERENCES employee.user(id) UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);