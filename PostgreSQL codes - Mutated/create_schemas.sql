CREATE SCHEMA IF NOT EXISTS administration;
CREATE SCHEMA IF NOT EXISTS attendance;
CREATE SCHEMA IF NOT EXISTS company;
CREATE SCHEMA IF NOT EXISTS employee;
CREATE SCHEMA IF NOT EXISTS payroll;
CREATE SCHEMA IF NOT EXISTS performance;
CREATE SCHEMA IF NOT EXISTS project;
CREATE SCHEMA IF NOT EXISTS stakeholder;
CREATE SCHEMA IF NOT EXISTS "transaction";

\i company_employee_init.sql

\i schema_company.sql
\i schema_employee.sql
\i schema_administration.sql
\i schema_attendance.sql
\i schema_transaction.sql
\i schema_payroll.sql
\i schema_project.sql
\i schema_performance.sql
\i schema_stakeholder.sql

\i flow_indexing.sql

-- Execute the following command to setup
-- psql -U postgres -h 127.0.0.1 -p 5432 -d flow -f create_schemas.sql