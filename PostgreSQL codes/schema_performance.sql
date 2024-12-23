CREATE TABLE IF NOT EXISTS performance.evaluation_type (
	pet_id SERIAL PRIMARY KEY,
	evaluation_type VARCHAR(50) NOT NULL,
	CHECK(evaluation_type IN('Supervisor Feedback','Peer-to-peer Feedback','Project-based Feedback')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id)
);

CREATE TABLE IF NOT EXISTS performance.evaluation_metric (
	pem_id SERIAL PRIMARY KEY,
	metric VARCHAR(50) NOT NULL,
	CHECK(metric IN('Job Knowledge and Expertise','Quality of Work','Productivity and Efficiency','Communication Skills','Problem-Solving and Innovation','Teamwork and Collaboration','Adaptability and Flexibility','Reliability and Accountability','Goal Completion','Commitment to Growth and Learning'))
);

CREATE TABLE IF NOT EXISTS performance.supervisor_rating ( -- when 'Supervisor Feedback' is chosen || only possible when HR opens the portal
	psr_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.supervisor(supervisor_id) NOT NULL, -- check whether supervisor or not
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	job_knowledge_and_expertise SMALLINT NOT NULL, -- from 1 to 5
	quality_of_work SMALLINT NOT NULL, -- from 1 to 5
	productivity_and_efficiency SMALLINT NOT NULL, -- from 1 to 5
	communication_skills SMALLINT NOT NULL, -- from 1 to 5
	problem_solving_and_innovation SMALLINT NOT NULL, -- from 1 to 5
	teamwork_and_collaboration SMALLINT NOT NULL, -- from 1 to 5
	adaptability_and_flexibility SMALLINT NOT NULL, -- from 1 to 5
	reliability_and_accountability SMALLINT NOT NULL, -- from 1 to 5
	goal_completion SMALLINT NOT NULL, -- from 1 to 5
	commitment_to_growth_and_learning SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);

CREATE TABLE IF NOT EXISTS performance.peer_rating ( -- when 'Peer-to-peer Feedback' is chosen || only possible when HR opens the portal
	peer_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	teamwork_and_cooperation SMALLINT NOT NULL, -- from 1 to 5
	communication_effectiveness SMALLINT NOT NULL, -- from 1 to 5
	conflict_resolution SMALLINT NOT NULL, -- from 1 to 5
	active_listening SMALLINT NOT NULL, -- from 1 to 5
	supportiveness SMALLINT NOT NULL, -- from 1 to 5
	respect_and_professionalism SMALLINT NOT NULL, -- from 1 to 5
	trustworthiness SMALLINT NOT NULL, -- from 1 to 5
	adaptability_in_team_dynamics SMALLINT NOT NULL, -- from 1 to 5
	workload_balance_contribution SMALLINT NOT NULL, -- from 1 to 5
	peer_mentorship SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);

CREATE TABLE IF NOT EXISTS performance.project_rating ( -- when 'Project Feedback' is chosen || only possible when HR opens the portal
	ppr_id SERIAL PRIMARY KEY,
	rater INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	ratee INTEGER REFERENCES employee.employee(employee_id) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP,
	project INTEGER REFERENCES project.project_record(project_id) NOT NULL,
	company INTEGER REFERENCES company.company(company_id) NOT NULL,
	task_completion_efficiency SMALLINT NOT NULL, -- from 1 to 5
	quality_of_deliverables SMALLINT NOT NULL, -- from 1 to 5
	responsiveness SMALLINT NOT NULL, -- from 1 to 5
	initiave_in_problem_solving SMALLINT NOT NULL, -- from 1 to 5
	goal_alignment SMALLINT NOT NULL, -- from 1 to 5
	team_contribution SMALLINT NOT NULL, -- from 1 to 5
	collaboration_with_team_members SMALLINT NOT NULL, -- from 1 to 5
	adaptability_under_pressure SMALLINT NOT NULL, -- from 1 to 5
	accountability SMALLINT NOT NULL, -- from 1 to 5
	work_ethic SMALLINT NOT NULL, -- from 1 to 5
	overall_rating INT NOT NULL,
	key_strength TEXT,
	areas_to_improve TEXT
);