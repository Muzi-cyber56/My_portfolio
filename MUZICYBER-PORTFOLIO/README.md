# Sentinel — OSINT Investigation Platform

Flutter mobile/web + ASP.NET Core 10 + Entity Framework Core + **Microsoft SQL Server**.

Black, blue and white investigation UI with case management, OSINT research tools, image metadata, optional OCR, evidence integrity, relationship graph and PDF reports. The supplied directory layout is preserved; platform runners, project files, shared widgets and scripts are added where needed.

## Run locally (Windows)

Prerequisites: .NET 10 SDK, SQL Server Express (or another SQL Server instance), Flutter SDK. Node.js is only needed for the optional static preview and HTTP smoke test.

From this directory:
```powershell
.\scripts\Start-Backend.ps1
```
The script generates an ignored local signing key if needed and runs the API at http://localhost:5240. The development profile creates **OSINTPlatform** in your selected SQL Server instance on first run. The current machine has been configured with its local SQLEXPRESS instance; other machines can pass `-SqlServer '.\SQLEXPRESS'`.

In another terminal:
```powershell
.\scripts\Start-Mobile.ps1 -Device chrome
```
Create an account in the app (username 3-50 characters, password at least 12). Create a case, select it in the top bar, then choose a research or evidence tool.

For an Android emulator:
```powershell
.\scripts\Start-Mobile.ps1 -Device emulator-5554 -ApiBaseUrl http://10.0.2.2:5240
```
Use `flutter devices` to find the device ID. A physical phone needs a reachable development server address; configure HTTPS and bind the API intentionally. Production builds must use an HTTPS `API_BASE_URL`.

## Manual server configuration
Use environment variables or user secrets for `Jwt:Key` and `ConnectionStrings:DefaultConnection`. Never commit credentials. Local overrides belong in ignored backend/OSINTPlatform.API/appsettings.Local.json.

The development connection uses integrated Windows authentication and trusts the local SQL Server certificate. Production should validate the server certificate and use a restricted database account. `Storage:Root` resolves relative to the API directory; its default is the project root.

Optional local OCR: install Tesseract from a trusted distribution, including English trained data, and set `Forensics:TesseractPath` to its absolute executable path in local settings. EXIF extraction works without OCR.

## What works
- JWT authentication, owner-scoped case CRUD and analyst role.
- Phone/email validation, username research links, live DNS, IP analysis and CNIC format validation.
- PNG/JPEG/PDF/TXT evidence uploads with SHA-256, private storage and verification.
- Image dimensions and available EXIF metadata; optional Tesseract OCR.
- Case-membership graph and repeated input hashes.
- Downloadable PDF reports and evidence hashes rechecked at generation.

Profile URLs are leads, not verified accounts. There is no NADRA/subscriber/private identity connection. PDFs currently use ASCII text; see [limitations](docs/Project-Report/Limitations.md).

## Checks
```powershell
cd backend
dotnet test OSINTPlatform.sln
node OSINTPlatform.Tests/smoke.mjs
cd ../mobile_app
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```
The smoke script creates synthetic demonstration data and an ignored local preview session. It does not use real personal evidence.

To serve a built web preview:
```powershell
node scripts/serve-preview.mjs
```
Open http://localhost:8080 while the API is running.

## Structure
- mobile_app/ — requested Dart models, services, screens, widgets, tests and native/web runners.
- backend/ — the requested API, Core, Infrastructure and Tests assemblies.
- database/ — model-generated SQL Server schema and optional seed script.
- evidence/ and reports/ — runtime storage (ignored by Git).
- docs/Project-Report/ — all twelve requested project-report documents.
- docs/diagrams/ — architecture, ERD, data-flow and OSINT-workflow PNGs.
- scripts/ — local setup and preview helpers.

Read [API documentation](docs/Project-Report/API-Documentation.md), [security](docs/Project-Report/Security.md), [testing](docs/Project-Report/Testing.md) and [results](docs/Project-Report/Results.md).

Dependency references: [Microsoft SQL Server EF Core provider](https://learn.microsoft.com/en-us/ef/core/providers/sql-server/), [MetadataExtractor](https://www.nuget.org/packages/MetadataExtractor/2.9.3), [Flutter secure storage](https://pub.dev/packages/flutter_secure_storage).
