# Testing
Run from backend:
```powershell
dotnet test OSINTPlatform.sln
node OSINTPlatform.Tests/smoke.mjs
```
The smoke script requires the local development API and creates isolated demonstration accounts/cases. It exercises 40 HTTP checks against SQL Server, including cross-owner access, invalid input, persisted OSINT results, uploads, forged signatures, image properties, tamper detection, blocked mismatched downloads, report downloads and empty/non-empty case deletion. Its synthetic records remain available for manual preview. A random test password is stored only under ignored tmp/preview-session.json.

Unit tests cover password hashing, malformed hashes, credential constraints, case constraints, SQL relationship/index generation, unsafe domain input, lead confidence, address classification, known SHA-256, modified evidence, rejected files and PDF escaping/pagination.

Run from mobile_app:
```powershell
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```
Flutter tests cover validators, required login inputs and the registration toggle. Browser QA uses the actual Flutter build at desktop and 390-pixel mobile width. See Results.md for observed outcomes and Limitations.md for unverified areas.

Do not interpret these checks as a penetration test or comprehensive forensic validation.
