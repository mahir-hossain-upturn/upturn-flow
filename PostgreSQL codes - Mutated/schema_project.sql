CREATE TABLE IF NOT EXISTS project.record (
    id SERIAL PRIMARY KEY,
    project_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	project_lead_id uuid REFERENCES employee.employee(id) NOT NULL,
	remark TEXT, -- project conclusion / closing remark
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
	department_id INTEGER REFERENCES company.dept(id) NOT NULL,
	progress DECIMAL(3,2) NOT NULL -- =(milestone_progression / no. of milestone * 100)
);

CREATE TABLE IF NOT EXISTS project.project_status (
	id SERIAL PRIMARY KEY,
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'ARCHIEVED')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

-- CREATE TABLE IF NOT EXISTS project.project_dept (
-- 	id SERIAL PRIMARY KEY,
-- 	project_id INTEGER REFERENCES project.record(id),
-- 	department_id INTEGER REFERENCES company.dept(id),
-- 	company_id INTEGER REFERENCES company.company(id)
-- );

-- CREATE TABLE IF NOT EXISTS project.project_progression (
-- 	id SERIAL PRIMARY KEY,
-- 	progress DECIMAL(3,2) NOT NULL, -- =(milestone_progression / no. of milestone * 100)
-- 	project_id INTEGER REFERENCES project.record(id),
-- 	company_id INTEGER REFERENCES company.company(id)
-- );

CREATE TABLE IF NOT EXISTS project.project_outcome (
	id SERIAL PRIMARY KEY,
	expected_outcome VARCHAR(200) NOT NULL,
	result VARCHAR(20) NOT NULL,
	CHECK (result IN ('NOT_ACHIEVED', 'ACHIEVED')), -- not null after project == completed
	achievement DECIMAL(3,2) NOT NULL, -- default value assignment. Can be changed.
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

ALTER TABLE project.record
ADD COLUMN IF NOT EXISTS status_id INTEGER REFERENCES project.project_status (id);

-- ALTER TABLE project.record
-- ADD COLUMN IF NOT EXISTS progress_id INTEGER REFERENCES project.project_progression(id);

ALTER TABLE project.record
ADD COLUMN IF NOT EXISTS outcome_id INTEGER REFERENCES project.project_outcome(id);

CREATE TABLE IF NOT EXISTS project.milestone_record (
	id SERIAL PRIMARY KEY,
	milestone_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL, -- is determined by the earliest start date of a task under this milestone
    end_date DATE NOT NULL, -- is determined by the end date of the latest task under this milestone
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED')), -- (if a task has been created and assigned == 'In_Progress', otherwise == 'Not_Started') (if sum of task progression = 100, 'Completed', otherwise, 'In-Progress')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
	progress DECIMAL(3,2) NOT NULL -- (== no. of task completed / total no. of tasks in this milestone)
);

CREATE TABLE IF NOT EXISTS project.milestone_assignment (
	id SERIAL PRIMARY KEY,
	milestone_id INTEGER REFERENCES project.milestone_record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL,
	assignee_id uuid REFERENCES employee.employee(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS project.milestone_comment (
	id SERIAL PRIMARY KEY,
	comment TEXT,
	commenter_id uuid REFERENCES employee.employee(id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- comments can be edited for 1st 30 mins
	milestone_id INTEGER REFERENCES project.milestone_record(id) NOT NULL,
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

-- CREATE TABLE IF NOT EXISTS project.milestone_progression (
-- 	id SERIAL PRIMARY KEY,
-- 	progress DECIMAL(3,2) NOT NULL, -- (== no. of task completed / total no. of tasks in this milestone)
-- 	milestone_id INTEGER REFERENCES project.milestone_record(id),
-- 	project_id INTEGER REFERENCES project.record(id),
-- 	company_id INTEGER REFERENCES company.company(id)
-- );

-- ALTER TABLE project.project_dept
-- ADD COLUMN IF NOT EXISTS company_id INTEGER REFERENCES company.company(id);

CREATE TABLE IF NOT EXISTS project.task_record (
	id SERIAL PRIMARY KEY,
	task_title VARCHAR(200) NOT NULL,
	task_description TEXT,
	start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	status BOOLEAN DEFAULT FALSE NOT NULL, -- False = Not Done, True = Done
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	milestone_id INTEGER REFERENCES project.milestone_record(id) NOT NULL,
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS project.task_assignment (
	id SERIAL PRIMARY KEY,
	task_id INTEGER REFERENCES project.task_record(id) NOT NULL, 
	assignee_id uuid REFERENCES employee.employee(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS project.task_update (
	id SERIAL PRIMARY KEY,
	issue TEXT NOT NULL,
	resolved BOOLEAN DEFAULT FALSE,
	supported_by uuid[] NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	issuer_id uuid REFERENCES employee.employee(id) NOT NULL,
	task_id INTEGER REFERENCES project.task_record(id) NOT NULL,
	milestone_id INTEGER REFERENCES project.milestone_record(id) NOT NULL,
	project_id INTEGER REFERENCES project.record(id) NOT NULL,
	company_id INTEGER REFERENCES company.company(id) NOT NULL
);