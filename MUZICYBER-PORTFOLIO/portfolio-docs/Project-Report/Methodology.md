# Methodology
1. Translate the supplied architecture into three .NET assemblies: Core contracts, Infrastructure services and API endpoints.
2. Use SQL Server foreign keys and unique indexes with EF Core. Generate the SQL script directly from the model to prevent schema drift.
3. Authenticate before owner-scoped case operations. Return 404 for both missing and other users' cases.
4. Validate input locally. Execute only bounded DNS resolution as automated network research; retain other URLs as unverified leads.
5. Validate evidence size/signature, calculate its hash, extract metadata, store generated filenames outside public hosting, and persist the database row. Remove a newly written file if its database save fails.
6. Recompute evidence hashes on verification, download and report generation.
7. Verify with unit tests, real SQL Server/API checks, Flutter tests, analyzer, release web build and browser layout inspection.
