
CREATE TABLE IF NOT EXISTS company.country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS company.industry (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- did input for all the possible industry for data validation
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.country_industry ( -- this table works as the input field for country & industry when a company registers
id SERIAL PRIMARY KEY,
country_id INTEGER REFERENCES company.country(id) NOT NULL,
industry_id INTEGER REFERENCES company.industry(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS company.company (
id SERIAL PRIMARY KEY NOT NULL,
name VARCHAR(100) NOT NULL,
code VARCHAR(50) UNIQUE NOT NULL, -- data validation required to ask for more than 8 characters, 1 uc, 1lc, 1 special
industry_id INTEGER REFERENCES company.country_industry(id) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL -- at update
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS employee.user ( -- used for AUTHENTICATION & AUTHORIZATION with Supabase
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE NOT NULL, -- every session lasts for 60 minutes. If no activity for 60 minutes, the account logs out automatically. Account is only active if the tab / app is open last & last activity < 60 mins ago.
    last_login TIMESTAMP NOT  NULL, -- is used to count session duration
    has_approval BOOLEAN DEFAULT FALSE NOT NULL -- (to start/stop user usage)
);

CREATE TABLE IF NOT EXISTS employee.employee (
    id SERIAL PRIMARY KEY,
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

ALTER TABLE employee.user 
ADD COLUMN IF NOT EXISTS employee_id INTEGER REFERENCES employee.employee(id) UNIQUE;