-- Core Organization Structure
CREATE TABLE companies (
    company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE industries (
    industry_id VARCHAR(10) PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE company_industry (
    company_id VARCHAR(10) REFERENCES companies(company_id),
    industry_id VARCHAR(10) REFERENCES industries(industry_id),
    PRIMARY KEY (company_id, industry_id)
);

CREATE TABLE departments (
    department_id VARCHAR(20) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    department_name VARCHAR(100) NOT NULL,
    department_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE positions (
    position_id VARCHAR(20) PRIMARY KEY,
    department_id VARCHAR(20) REFERENCES departments(department_id),
    position_name VARCHAR(100) NOT NULL,
    position_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee Management
CREATE TABLE employees (
    employee_id VARCHAR(20) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employee_positions (
    employee_id VARCHAR(20) REFERENCES employees(employee_id),
    position_id VARCHAR(20) REFERENCES positions(position_id),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT true,
    PRIMARY KEY (employee_id, position_id, start_date)
);

CREATE TABLE employee_personal_info (
    employee_id VARCHAR(20) PRIMARY KEY REFERENCES employees(employee_id),
    date_of_birth DATE,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    marital_status VARCHAR(20),
    nid_no VARCHAR(50) UNIQUE,
    religion VARCHAR(50),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(50)
);

-- Address Management
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    street_address TEXT NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    address_type VARCHAR(20) -- 'PRESENT', 'PERMANENT', 'OFFICE'
);

CREATE TABLE employee_addresses (
    employee_id VARCHAR(20) REFERENCES employees(employee_id),
    address_id INTEGER REFERENCES addresses(address_id),
    address_type VARCHAR(20) NOT NULL,
    PRIMARY KEY (employee_id, address_id)
);

-- Leave Management
CREATE TABLE leave_types (
    leave_type_id VARCHAR(10) PRIMARY KEY,
    leave_type_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE leave_policies (
    policy_id VARCHAR(10) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    leave_type_id VARCHAR(10) REFERENCES leave_types(leave_type_id),
    annual_quota INTEGER NOT NULL,
    carries_forward BOOLEAN DEFAULT false,
    max_carry_forward INTEGER DEFAULT 0
);

CREATE TABLE leave_requests (
    leave_id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) REFERENCES employees(employee_id),
    leave_type_id VARCHAR(10) REFERENCES leave_types(leave_type_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(20) NOT NULL, -- 'PENDING', 'APPROVED', 'REJECTED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance Management
CREATE TABLE site_locations (
    location_id VARCHAR(20) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    location_name VARCHAR(100) NOT NULL,
    coordinates POINT,
    address_id INTEGER REFERENCES addresses(address_id)
);

CREATE TABLE work_shifts (
    shift_id VARCHAR(10) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    shift_name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

CREATE TABLE attendance_records (
    attendance_id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) REFERENCES employees(employee_id),
    attendance_date DATE NOT NULL,
    check_in_time TIMESTAMP,
    check_in_location POINT,
    check_out_time TIMESTAMP,
    check_out_location POINT,
    shift_id VARCHAR(10) REFERENCES work_shifts(shift_id),
    status VARCHAR(20) NOT NULL, -- 'PRESENT', 'ABSENT', 'LATE', 'HALF_DAY'
    UNIQUE (employee_id, attendance_date)
);

-- Performance Management
CREATE TABLE kpi_categories (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE kpis (
    kpi_id VARCHAR(20) PRIMARY KEY,
    category_id VARCHAR(10) REFERENCES kpi_categories(category_id),
    position_id VARCHAR(20) REFERENCES positions(position_id),
    kpi_name VARCHAR(100) NOT NULL,
    description TEXT,
    measurement_criteria TEXT,
    target_value DECIMAL(10,2),
    weight INTEGER
);

CREATE TABLE performance_reviews (
    review_id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) REFERENCES employees(employee_id),
    reviewer_id VARCHAR(20) REFERENCES employees(employee_id),
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    review_type VARCHAR(50) NOT NULL, -- 'ANNUAL', 'QUARTERLY', 'PROBATION'
    status VARCHAR(20) NOT NULL, -- 'DRAFT', 'SUBMITTED', 'APPROVED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE performance_review_details (
    review_id INTEGER REFERENCES performance_reviews(review_id),
    kpi_id VARCHAR(20) REFERENCES kpis(kpi_id),
    score DECIMAL(5,2) NOT NULL,
    comments TEXT,
    PRIMARY KEY (review_id, kpi_id)
);

-- Stakeholder Management
CREATE TABLE stakeholder_categories (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE stakeholders (
    stakeholder_id VARCHAR(20) PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id),
    category_id VARCHAR(10) REFERENCES stakeholder_categories(category_id),
    stakeholder_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address_id INTEGER REFERENCES addresses(address_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contracts (
    contract_id VARCHAR(20) PRIMARY KEY,
    stakeholder_id VARCHAR(20) REFERENCES stakeholders(stakeholder_id),
    start_date DATE NOT NULL,
    end_date DATE,
    contract_type VARCHAR(50) NOT NULL, -- 'ONE_TIME', 'RECURRING'
    status VARCHAR(20) NOT NULL, -- 'ACTIVE', 'EXPIRED', 'TERMINATED'
    terms TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Authentication and Authorization
CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE REFERENCES employees(employee_id),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP
);

CREATE TABLE roles (
    role_id VARCHAR(10) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE permissions (
    permission_id VARCHAR(20) PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE role_permissions (
    role_id VARCHAR(10) REFERENCES roles(role_id),
    permission_id VARCHAR(20) REFERENCES permissions(permission_id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id VARCHAR(20) REFERENCES users(user_id),
    role_id VARCHAR(10) REFERENCES roles(role_id),
    PRIMARY KEY (user_id, role_id)
);
