-- Core Organization Structure
CREATE TABLE IF NOT EXISTS companies (
    company_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS industries (
    industry_id SERIAL PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS company_industry (
    company_id INTEGER REFERENCES companies(company_id),
    industry_id INTEGER REFERENCES industries(industry_id),
    PRIMARY KEY (company_id, industry_id)
);

CREATE TABLE IF NOT EXISTS country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS company_country (
    country_id INTEGER REFERENCES country(country_id),
    company_id INTEGER REFERENCES companies(company_id),
    PRIMARY KEY (company_id, country_id)
);

CREATE TABLE IF NOT EXISTS currency (
    currency_id SERIAL PRIMARY KEY,
    currency_name VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS divisions (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(25),
    company_id INTEGER REFERENCES companies(company_id)
);

CREATE TABLE IF NOT EXISTS departments (
    department_id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    department_name VARCHAR(100) NOT NULL,
    department_description TEXT,
    division_id INTEGER REFERENCES divisions(division_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS units (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(25),
    department_id INTEGER REFERENCES departments(department_id)
);

CREATE TABLE IF NOT EXISTS positions (
    position_id SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES departments(department_id),
    position_name VARCHAR(100) NOT NULL,
    position_job_description TEXT,
    position_grade VARCHAR(10),
    salary_range_min DECIMAL(15,2),
    salary_range_max DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS company_departments (
    company_id INTEGER REFERENCES companies(company_id),
    department_id INTEGER REFERENCES departments(department_id),
    PRIMARY KEY (company_id, department_id) 
);

CREATE TABLE IF NOT EXISTS department_positions (
    department_id INTEGER REFERENCES departments(department_id),
    position_id INTEGER REFERENCES positions(position_id),
    PRIMARY KEY (department_id, position_id)
);

-- Employee Management
CREATE TABLE IF NOT EXISTS employees (
    company_id INTEGER REFERENCES companies(company_id),
    employee_id_input VARCHAR(10),
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employee_positions (
    employee_id INTEGER REFERENCES employees(employee_id),
    position_id INTEGER REFERENCES positions(position_id),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT true,
    starting_salary DECIMAL(15,2),
    change_reason TEXT,
    approved_by INTEGER REFERENCES employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, position_id)
);

-- Salary Management
CREATE TABLE IF NOT EXISTS salary_components (
    component_id SERIAL PRIMARY KEY,
    component_name VARCHAR(100) NOT NULL,
    component_type ENUM('Add','Subtract'),
    is_variable BOOLEAN,
    taxable BOOLEAN,
    description TEXT
);

INSERT INTO salary_components(component_type) VALUES ('Add');
INSERT INTO salary_components(component_type) VALUES ('Subtract');


CREATE TABLE IF NOT EXISTS employee_salary_component (
    PRIMARY KEY (company_id, employee_id, component_id),
    effective_date DATE NOT NULL,
    end_date DATE,
    payout BOOLEAN
);

CREATE TABLE IF NOT EXISTS fixed_component_records (
    PRIMARY KEY (company_id, employee_id, component_id),
    created_by INTEGER REFERENCES employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL (10,2),
    currency_id INTEGER REFERENCES currency(currency_id),
    remark VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS variable_component_records (
    PRIMARY KEY (company_id, employee_id, component_id),
    created_by INTEGER REFERENCES employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL (10,2),
    currency_id INTEGER REFERENCES currency(currency_id),
    remark VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS bank (
    bank_id SERIAL PRIMARY KEY,
    bank_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS bank_account (
    PRIMARY KEY (bank_id, employee_id),
    account_name VARCHAR(50),
    account_number INTEGER,
    branch_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS payroll_disbursement (
    disbursement_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    payment_month DATE, -- STORE '2024-03-31' as March 2024
    gross_amount INTEGER,
    net_amount INTEGER,
    approval_status ENUM('Approved','Rejected'),
    approved_by INTEGER REFERENCES employees(employee_id),
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(20)
);

INSERT INTO payroll_disbursement(approval_status) VALUES ('Approved');
INSERT INTO payroll_disbursement(approval_status) VALUES ('Rejected');

CREATE TABLE IF NOT EXISTS bank_transaction (
    transaction_id SERIAL PRIMARY KEY,
    disbursement_id INTEGER REFERENCES payroll_disbursement(disbursement_id),
    bank_account_id (bank_id, employee_id),
    payment_date DATE
);


-- Claims Management
CREATE TABLE IF NOT EXISTS claim_table (
    claim_type_id SERIAL PRIMARY KEY,
    claim_type VARCHAR(100) NOT NULL,
    description TEXT,
    company_id INTEGER REFERENCES companies(company_id),
);

CREATE TABLE IF NOT EXISTS claims (
    claim_id SERIAL PRIMARY KEY,
    claim_date DATE NOT NULL,
    claimant INTEGER REFERENCES employees(employee_id),
    claim_type_id INTEGER REFERENCES claim_table(claim_type_id),
    amount DECIMAL(10,2),
    attachment BLOB,
    approval_status ENUM('Approved','Rejected'),
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    approved_by INTEGER REFERENCES employees(employee_id)
);

-- Document Management
CREATE TABLE IF NOT EXISTS document_types (
    type_id VARCHAR(20) PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    requires_renewal BOOLEAN DEFAULT false,
    renewal_period_months INTEGER
);

CREATE TABLE IF NOT EXISTS documents (
    document_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50) NOT NULL,
    document_type VARCHAR(20) REFERENCES document_types(type_id),
    document_path VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by INTEGER REFERENCES employees(employee_id),
    expiry_date DATE,
    is_mandatory BOOLEAN DEFAULT false,
    CONSTRAINT valid_entity_type CHECK (entity_type IN ('EMPLOYEE', 'POSITION', 'COMPANY', 'LEAVE', 'NOTICE', 'COMPLAINT', 'CLAIMS', 'CONTRACT'))
);

-- Audit Trail
CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by INTEGER REFERENCES employees(employee_id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_action_type CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- Employee Personal Information
CREATE TABLE IF NOT EXISTS employee_personal_info (
    employee_id INTEGER PRIMARY KEY REFERENCES employees(employee_id),
    date_of_birth DATE,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    marital_status VARCHAR(20),
    nid_no VARCHAR(50) UNIQUE,
    religion VARCHAR(50),
    emergency_contact_name VARCHAR(50),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(15)
);

-- Address Management
CREATE TABLE IF NOT EXISTS addresses (
    address_id SERIAL PRIMARY KEY,
    street_address TEXT NOT NULL,
    city VARCHAR(50),
    state VARCHAR(100),
    postal_code VARCHAR(10),
    country INTEGER REFERENCES country(country_id),
    address_type VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS employee_addresses (
    employee_id INTEGER REFERENCES employees(employee_id),
    address_id INTEGER REFERENCES addresses(address_id),
    PRIMARY KEY (employee_id, address_id)
);

-- Leave Management
CREATE TABLE IF NOT EXISTS leave_types (
    leave_type_id SERIAL PRIMARY KEY,
    leave_type_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS leave_policies (
    policy_id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    leave_type_id INTEGER REFERENCES leave_types(leave_type_id),
    annual_quota INTEGER NOT NULL,
    approval_requirement BOOLEAN DEFAULT true,
    carries_forward BOOLEAN DEFAULT false,
    max_carry_forward INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS leave_requests (
    leave_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    leave_type_id INTEGER REFERENCES leave_types(leave_type_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_leave_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- Attendance Management
CREATE TABLE IF NOT EXISTS site_locations (
    location_id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    location_name VARCHAR(100) NOT NULL,
    coordinates POINT,
    check_in TIMESTAMP,
    check_out TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance_records (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    attendance_date DATE NOT NULL,
    location_id INTEGER REFERENCES site_locations(location_id),
    check_in_time TIMESTAMP,
    check_in_location POINT,
    check_out_time TIMESTAMP,
    check_out_location POINT,
    status VARCHAR(20) NOT NULL,
    UNIQUE (employee_id, attendance_date),
    CONSTRAINT valid_attendance_status CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'WRONG_LOCATION', 'DID_NOT_CHECK_OUT'))
);

-- Performance Management
CREATE TABLE IF NOT EXISTS kpi_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS kpis (
    kpi_id VARCHAR(20) PRIMARY KEY,
    category_id VARCHAR(10) REFERENCES kpi_categories(category_id),
    position_id INTEGER REFERENCES positions(position_id),
    kpi_name VARCHAR(100) NOT NULL,
    description TEXT,
    measurement_criteria TEXT,
    target_value DECIMAL(10,2),
    weight INTEGER
);

CREATE TABLE IF NOT EXISTS performance_reviews (
    review_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    reviewer_id INTEGER REFERENCES employees(employee_id),
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    review_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_review_type CHECK (review_type IN ('ANNUAL', 'QUARTERLY', 'MONTHLY')),
    CONSTRAINT valid_review_status CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED'))
);

CREATE TABLE IF NOT EXISTS performance_review_details (
    review_id INTEGER REFERENCES performance_reviews(review_id),
    kpi_id VARCHAR(20) REFERENCES kpis(kpi_id),
    score DECIMAL(5,2) NOT NULL,
    comments TEXT,
    PRIMARY KEY (review_id, kpi_id)
);

-- User Authentication and Authorization
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(20) PRIMARY KEY,
    employee_id INTEGER UNIQUE REFERENCES employees(employee_id),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
    role_id VARCHAR(10) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS permissions (
    permission_id VARCHAR(20) PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(10) REFERENCES roles(role_id),
    permission_id VARCHAR(20) REFERENCES permissions(permission_id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id VARCHAR(20) REFERENCES users(user_id),
    role_id VARCHAR(10) REFERENCES roles(role_id),
    PRIMARY KEY (user_id, role_id)
);

-- Stakeholder Management
CREATE TABLE IF NOT EXISTS stakeholder_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT valid_stakeholder_type CHECK (type_name IN ('Client', 'Supplier', 'Lead', 'Vendor'))
);

CREATE TABLE IF NOT EXISTS stakeholder_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT valid_category CHECK (category_name IN ('One-time', 'Ongoing', 'Recurring'))
);

CREATE TABLE IF NOT EXISTS stakeholders (
    stakeholder_id SERIAL PRIMARY KEY,
    stakeholder_type_id INTEGER REFERENCES stakeholder_types(type_id),
    category_id INTEGER REFERENCES stakeholder_categories(category_id),
    entity_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(20),
    contract_start_date DATE,
    contract_end_date DATE,
    company_id INTEGER REFERENCES companies(company_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Project Management
CREATE TABLE IF NOT EXISTS projects (
    project_id SERIAL PRIMARY KEY,
    project_title VARCHAR(200) NOT NULL,
    project_lead INTEGER REFERENCES employees(employee_id),
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) NOT NULL,
    department_id INTEGER REFERENCES departments(department_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_project_status CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED'))
);

CREATE TABLE IF NOT EXISTS milestones (
    milestone_id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(project_id),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    completion_percentage DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_milestone_status CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'ACHIEVED', 'NOT_ACHIEVED'))
);

CREATE TABLE IF NOT EXISTS tasks (
    task_id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(project_id),
    milestone_id INTEGER REFERENCES milestones(milestone_id),
    task_name VARCHAR(200) NOT NULL,
    description TEXT,
    department_id INTEGER REFERENCES departments(department_id),
    priority VARCHAR(10) NOT NULL,
    start_date DATE,
    deadline DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH'))
);

CREATE TABLE IF NOT EXISTS task_assignments (
    task_id INTEGER REFERENCES tasks(task_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    PRIMARY KEY (task_id, employee_id)
);

CREATE TABLE IF NOT EXISTS milestone_assignments (
    milestone_id INTEGER REFERENCES milestones(milestone_id),
    department_id INTEGER REFERENCES departments(department_id),
    PRIMARY KEY (milestone_id, department_id)
);

-- Activity Logging
CREATE TABLE IF NOT EXISTS activity_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT valid_activity_type CHECK (type_name IN ('Service Interaction', 'Product Interaction', 'Payment Interaction', 'Lead Interaction'))
);

CREATE TABLE IF NOT EXISTS activity_logs (
    activity_id SERIAL PRIMARY KEY,
    stakeholder_id INTEGER REFERENCES stakeholders(stakeholder_id),
    activity_type_id INTEGER REFERENCES activity_types(type_id),
    interaction_type VARCHAR(50) NOT NULL,
    description TEXT,
    quantity INTEGER,
    total_amount DECIMAL(15,2),
    employee_id INTEGER REFERENCES employees(employee_id),
    activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_interaction_type CHECK (interaction_type IN ('Give Product', 'Receive Product', 'Give Service', 'Receive Service', 'Give Payment', 'Receive Payment', 'Lead Update'))
);

-- Notice Board Management
CREATE TABLE IF NOT EXISTS notice_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT valid_notice_type CHECK (type_name IN ('General Announcement', 'HR Update', 'Administrative Notice', 'Event', 'Policy Update', 'Training/Workshop'))
);

CREATE TABLE IF NOT EXISTS notices (
    notice_id SERIAL PRIMARY KEY,
    notice_type_id INTEGER REFERENCES notice_types(type_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    department_id INTEGER REFERENCES departments(department_id),
    urgency_level VARCHAR(10) NOT NULL,
    posting_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_till DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_by INTEGER REFERENCES employees(employee_id),
    CONSTRAINT valid_urgency CHECK (urgency_level IN ('LOW', 'MEDIUM', 'HIGH')),
    CONSTRAINT valid_notice_status CHECK (status IN ('ACTIVE', 'ARCHIVED', 'EXPIRED'))
);

-- Complaint Management
CREATE TABLE IF NOT EXISTS complaint_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    definition TEXT,
    company_id INTEGER REFERENCES companies(company_id),
    CONSTRAINT valid_complaint_type CHECK (type_name IN ('Discrimination', 'Bullying', 'Harassment', 'Work Conditions', 'Workplace health & safety', 'Management', 'Work environment', 'Interpersonal Conflicts', 'Retaliation', 'Verbal abuse', 'Workload grievances', 'Workplace violence', 'Others'))
);

CREATE TABLE IF NOT EXISTS complaints (
    complaint_id VARCHAR(20) PRIMARY KEY,
    complaint_type_id VARCHAR(10) REFERENCES complaint_types(type_id),
    complainant_id INTEGER REFERENCES employees(employee_id),
    accused_id INTEGER REFERENCES employees(employee_id),
    department_id INTEGER REFERENCES departments(department_id),
    description TEXT,
    filing_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT valid_complaint_status CHECK (status IN ('NOT_STARTED', 'PENDING', 'RESOLVED'))
);

CREATE TABLE IF NOT EXISTS complaint_followups (
    followup_id SERIAL PRIMARY KEY,
    complaint_id VARCHAR(20) REFERENCES complaints(complaint_id),
    followup_text TEXT,
    status VARCHAR(20) NOT NULL,
    created_by INTEGER REFERENCES employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Package Management
CREATE TABLE IF NOT EXISTS package_types (
    pack_id VARCHAR(10) PRIMARY KEY,
    pack_name VARCHAR(50) NOT NULL,
    user_limit INTEGER,
    storage_limit_mb INTEGER,
    description TEXT
);

CREATE TABLE IF NOT EXISTS package_features (
    pack_id VARCHAR(10) REFERENCES package_types(pack_id),
    feature_name VARCHAR(50) NOT NULL,
    is_enabled BOOLEAN DEFAULT false,
    PRIMARY KEY (pack_id, feature_name),
    CONSTRAINT valid_feature CHECK (feature_name IN ('HRIS', 'Admin_Mgt', 'Project_Mgt', 'Stakeholder_Mgt', 'Report', 'Process_Mgt', 'Performance_Mgt'))
);

CREATE TABLE IF NOT EXISTS company_packages (
    company_id INTEGER REFERENCES companies(company_id),
    pack_id VARCHAR(10) REFERENCES package_types(pack_id),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (company_id, pack_id, start_date),
    CONSTRAINT valid_package_status CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED'))
);

-- Additional Indexes for Performance
CREATE INDEX idx_employee_email ON employees(email);
CREATE INDEX idx_attendance_date ON attendance_records(attendance_date);
CREATE INDEX idx_leave_dates ON leave_requests(start_date, end_date);
CREATE INDEX idx_project_dates ON projects(start_date, end_date);
CREATE INDEX idx_task_deadline ON tasks(deadline);
CREATE INDEX idx_notice_dates ON notices(posting_date, valid_till);
CREATE INDEX idx_stakeholder_type ON stakeholders(stakeholder_type_id);
CREATE INDEX idx_activity_date ON activity_logs(activity_date);
