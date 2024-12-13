# Current Plan - 17th Nov 2024

Your proposed simplification of the tech stack is an excellent idea for improving maintainability, reducing complexity, and cutting costs. Using PostgreSQL as a monolithic backend through extensions like pg_trunk and tools like PostgREST is a powerful approach. Below, I’ll evaluate this plan and provide step-by-step recommendations to make it robust and scalable.

## Advantage of the Approach
1. Simplified Architecture:
Consolidates all backend functionalities within PostgreSQL, reducing dependencies on external services like Redis, Elasticsearch, Azure, or Supabase.

2. Cost-Effectiveness:
Avoids costs associated with multiple services and simplifies infrastructure management.

3. Performance:
Reduces latency since data doesn’t need to be transferred between different systems.
Utilizes PostgreSQL's efficient indexing, query optimizations, and extensions.

4. Maintainability:
Fewer moving parts lead to easier debugging and monitoring.

## Potential Problems

1. Scalability:
PostgreSQL can handle a lot, but centralizing all functionality (search, caching, notifications, etc.) might strain the system in high-traffic scenarios.

2. BLOB Storage Limitations:
Storing large binary files (e.g., PDFs, images) directly in PostgreSQL might lead to performance and storage inefficiencies.

3. Search Limitations:
PostgreSQL’s full-text search is powerful but might not match the advanced search capabilities of Elasticsearch for highly complex queries.

4. Learning Curve:
Fully leveraging PostgreSQL's extensions (e.g., Trunk, PL/pgSQL functions) may require deep expertise.

## Step-by-Step Implementation Recommendations
Here’s how to implement your simplified stack effectively:

### a. Use pg_trunk for Consolidated Backend Features
pg_trunk is a great choice to add additional PostgreSQL functionalities without needing external services.

1) <b> Set Up Authentication </b>: 
Use pg_trunk’s authentication capabilities to handle user roles and permissions.
Example: Add role-based access controls (RBAC) and enforce row-level security (RLS).

```
CREATE POLICY user_access_policy
ON tasks
FOR SELECT
USING (user_id = current_user);
```

2) <b> Indexing for Performance </b>:
Use pg_trunk for automatic and manual indexing:
```
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
```

3) <b> Caching </b>:
Use pg_trunk or PostgreSQL's materialized views for frequently accessed data.

```
CREATE MATERIALIZED VIEW cached_data AS
SELECT * FROM tasks WHERE status = 'active';
```

4) <b> Search Functionality </b>:
Leverage PostgreSQL's GIN/GIN_TRGM indexes for advanced full-text search.

```
CREATE INDEX idx_tasks_search ON tasks USING gin(to_tsvector('english', title || ' ' || description));
SELECT * FROM tasks WHERE to_tsvector('english', title || ' ' || description) @@ to_tsquery('project');
```

5) <b> BLOB Storage </b>:
Store small files using pg_trunk, but for larger files:

Use pg_largeobject for binary data.
Alternatively, store only metadata in PostgreSQL and keep the actual files in a CDN like AWS S3 or Azure Blob Storage.

### b. Use PostgREST for RESTful APIs
PostgREST is an excellent choice for building RESTful APIs directly from PostgreSQL.

1) <b> Setup PostgREST </b>:

Install and configure PostgREST to connect to your PostgreSQL instance. Map API routes to database tables and views.

2) <b> Implement Access Control </b>:

Use PostgreSQL policies to restrict API access to specific rows or columns based on user roles.
```
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_policy
ON tasks
FOR SELECT
USING (user_id = current_user);
```

3) <b> Extend API Functionality </b>:

Define custom SQL functions and expose them through PostgREST for complex operations.
```
CREATE FUNCTION add_task(title TEXT, description TEXT) RETURNS VOID AS $$
BEGIN
    INSERT INTO tasks (title, description, user_id) VALUES (title, description, current_user);
END;
$$ LANGUAGE plpgsql;
```

4) <b> Versioning </b>:

Use schemas for API versioning (e.g., v1.tasks, v2.tasks).

### b. PostgreSQL for Notifications
PostgreSQL's built-in NOTIFY/LISTEN system is perfect for lightweight real-time notifications.

1) Enable Notifications:

Set up triggers to send notifications on data changes.
```
CREATE OR REPLACE FUNCTION notify_task_change()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('task_changes', row_to_json(NEW)::TEXT);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_notify
AFTER INSERT OR UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION notify_task_change();
```

2) Consume Notifications:

Use a WebSocket or long-polling mechanism in your backend/frontend to listen for notifications from PostgreSQL.

```
import psycopg2
conn = psycopg2.connect(dsn)
conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
cur = conn.cursor()
cur.execute("LISTEN task_changes;")
while True:
    conn.poll()
    while conn.notifies:
        notify = conn.notifies.pop(0)
        print(f"Received: {notify.payload}")
```

## General Recommendations

1. Scale PostgreSQL Horizontally:

Use pg_bouncer for connection pooling to handle high concurrency.
Use read replicas for read-heavy workloads.

2. Set Up Monitoring:

Use tools like pgAdmin, Datadog, or Prometheus to monitor query performance and system health.

3. Plan for Backups:

Set up regular backups using pg_dump or tools like pgBackRest.

4. Prepare for Search Scalability:

If PostgreSQL full-text search becomes a bottleneck, consider switching to ZomboDB (Elasticsearch integration for PostgreSQL) for seamless migration.

5. Optimize Costs for BLOB Storage:

Store large files in a separate, cost-effective solution (e.g., AWS S3, Wasabi) and only manage metadata in PostgreSQL.


## Conclusion