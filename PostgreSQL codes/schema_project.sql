CREATE TABLE project.project_record (
    project_id SERIAL PRIMARY KEY,
    project_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	project_lead INTEGER REFERENCES employee.employee(employee_id),
	remark TEXT, -- project conclusion / closing remark
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_status (
	pstatus_id SERIAL PRIMARY KEY,
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'ARCHIEVED')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_dept (
	pdept_id SERIAL PRIMARY KEY,
	project INTEGER REFERENCES project.project_record(project_id),
	department INTEGER REFERENCES company.department(dept_id)
);

CREATE TABLE project.project_progression (
	p_progress_id SERIAL PRIMARY KEY,
	progress DECIMAL(3,2) NOT NULL, -- =(milestone_progression / no. of milestone * 100)
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.project_outcome (
	p_outcome_id SERIAL PRIMARY KEY,
	p_outcome VARCHAR(200) NOT NULL,
	p_result VARCHAR(20) NOT NULL,
	CHECK (p_result IN ('NOT_ACHIEVED', 'ACHIEVED')), -- not null after project == completed
	achievement DECIMAL(3,2) NOT NULL, -- default value assignment. Can be changed.
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

ALTER TABLE project.project_record
ADD COLUMN status INTEGER REFERENCES project.project_status (pstatus_id);

ALTER TABLE project.project_record
ADD COLUMN progress INTEGER REFERENCES project.project_progression(p_progress_id);

ALTER TABLE project.project_record
ADD COLUMN outcome INTEGER REFERENCES project.project_outcome(p_outcome_id);

CREATE TABLE project.milestone_record (
	milestone_id SERIAL PRIMARY KEY,
	milestone_title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL, -- is determined by the earliest start date of a task under this milestone
    end_date DATE NOT NULL, -- is determined by the end date of the latest task under this milestone
	status VARCHAR(20) NOT NULL,
	CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED')), -- (if a task has been created and assigned == 'In_Progress', otherwise == 'Not_Started') (if sum of task progression = 100, 'Completed', otherwise, 'In-Progress')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_assignment (
	ma_id SERIAL PRIMARY KEY,
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	assignee INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_comment (
	mc_id SERIAL PRIMARY KEY,
	mcomment TEXT,
	commentor INTEGER REFERENCES employee.employee(employee_id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- comments can be edited for 1st 30 mins
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.milestone_progression (
	mp_id SERIAL PRIMARY KEY,
	progress DECIMAL(3,2) NOT NULL, -- (== no. of task completed / total no. of tasks in this milestone)
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

ALTER TABLE project.project_dept
ADD COLUMN company INTEGER REFERENCES company.company(company_id);

CREATE TABLE project.task_record (
	task_id SERIAL PRIMARY KEY,
	task_title VARCHAR(200) NOT NULL,
	task_description TEXT,
	start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	status BOOLEAN DEFAULT FALSE NOT NULL, -- False = Not Done, True = Done
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP NOT NULL, -- on update
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.task_assignment (
	ta_id SERIAL PRIMARY KEY,
	task INTEGER REFERENCES project.task_record(task_id), 
	assignee INTEGER REFERENCES employee.employee(employee_id),
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE project.task_update (
	tu_id SERIAL PRIMARY KEY,
	task INTEGER REFERENCES project.task_record(task_id),
	has_issue BOOLEAN DEFAULT FALSE,
	milestone INTEGER REFERENCES project.milestone_record(milestone_id),
	project INTEGER REFERENCES project.project_record(project_id),
	company INTEGER REFERENCES company.company(company_id)
);