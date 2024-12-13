CREATE TABLE company.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL
);

CREATE TABLE company.industry (
    industry_id SERIAL PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL -- did input for all the possible industry for data validation
    updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.country_industry ( -- this table works as the input field for country & industry when a company registers
ci_id SERIAL PRIMARY KEY,
country INTEGER REFERENCES company.country(country_id) NOT NULL,
industry INTEGER REFERENCES company.industry(industry_id) NOT NULL
);

CREATE TABLE company.currency (
    currency_code VARCHAR(3) PRIMARY KEY,
	currency_name VARCHAR(25) NOT NULL
);

CREATE TABLE company.company (
company_id SERIAL PRIMARY KEY NOT NULL,
company_name VARCHAR(100) NOT NULL,
company_code VARCHAR(50) UNIQUE NOT NULL, -- data validation required to ask for more than 8 characters, 1 uc, 1lc, 1 special
country_industry INTEGER REFERENCES company.country_industry(ci_id) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL -- at update
);

CREATE TABLE company.division (
    div_id SERIAL PRIMARY KEY,
    div_name VARCHAR(50) NOT NULL,
    div_head INTEGER REFERENCES employee.employee(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL, -- at update
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);

CREATE TABLE company.department (
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
    country INTEGER REFERENCES company.country(country_id) NOT NULL
    company INTEGER REFERENCES company.company(company_id) NOT NULL
);