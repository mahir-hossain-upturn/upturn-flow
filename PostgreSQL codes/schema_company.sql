-- Active: 1734942825534@@127.0.0.1@5432@flow
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

CREATE TABLE IF NOT EXISTS company.currency (
    code VARCHAR(3) PRIMARY KEY,
	name VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS company.company (
id SERIAL PRIMARY KEY NOT NULL,
name VARCHAR(100) NOT NULL,
code VARCHAR(50) UNIQUE NOT NULL, -- data validation required to ask for more than 8 characters, 1 uc, 1lc, 1 special
industry_id INTEGER REFERENCES company.country_industry(id) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.division (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    head_id INTEGER REFERENCES employee.employee(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL, -- at update
    company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS company.department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    head_id INTEGER REFERENCES employee.employee(id),
    description TEXT, -- input the JD here || create a rich text dialog box
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.unit (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    head_id INTEGER REFERENCES employee.employee(id),
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.position (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    jd TEXT,
    grade VARCHAR(10),
    salary_range_min DECIMAL(10,2),
    salary_range_max DECIMAL(10,2),
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.designation (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    division_id INTEGER REFERENCES company.division(id),
    dept_id INTEGER REFERENCES company.dept(id),
    unit_id INTEGER REFERENCES company.unit(id),
    position_id INTEGER REFERENCES company.position(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CHECK(role_name IN('Super Admin','Admin','HR','Supervisor','End User')),
    company_id INTEGER REFERENCES company.company(id) NOT NULL,
    employee_id INTEGER REFERENCES employee.employee(id) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE IF NOT EXISTS company.address ( 
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL,
    CHECK(address_type IN('Employee','Client','Supplier','Vendor','Lead')),
    street_address VARCHAR(100) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state VARCHAR(20),
    postal_code VARCHAR(10),
    country INTEGER REFERENCES company.country(id) NOT NULL
    company INTEGER REFERENCES company.company(id) NOT NULL
);