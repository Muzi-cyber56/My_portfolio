# Database design
The SQL Server schema in database/schema.sql is generated from ApplicationDbContext. It uses uniqueidentifier primary keys, nvarchar text, datetimeoffset UTC timestamps, bigint for evidence sizes and audit IDs, and float for confidence.

| Table | Purpose | Relationships |
|---|---|---|
| Users | Normalized username, salted password hash and role | Cases.CreatedBy |
| Cases | Number, title, scope, status and priority | Owner is a User |
| Investigations | Input type and SHA-256 of trimmed/lowercased input | CaseId |
| Findings | Observation/lead value, source URL and confidence | InvestigationId |
| Evidence | Original filename, MIME, source, generated private path, hash, metadata JSON and verification time | CaseId |
| Reports | Private PDF path and creation time | CaseId |
| AuditLogs | User ID if authenticated, method/path/status, timestamp and request IP | Nullable attribution; no request body |

Case numbers and usernames have unique indexes. Case foreign keys restrict deletes. A case containing investigations, evidence or reports must be closed rather than deleted. Empty cases can be deleted.

The initial development database is created using EnsureCreated; this is not a migration system. On an existing database, future schema changes require reviewed EF migrations or SQL change scripts. Do not run EnsureCreated against an unrelated or shared schema. Back up SQL data and private evidence/report directories together.

Input hashes are deterministic correlation keys, not anonymization or protection against guessing. Findings and evidence metadata may contain sensitive values.
