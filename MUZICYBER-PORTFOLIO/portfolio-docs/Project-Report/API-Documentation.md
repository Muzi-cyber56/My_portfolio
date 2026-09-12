# REST API
Base URL for local development: http://localhost:5240. JSON fields use camelCase. All /api endpoints except authentication require Authorization: Bearer <token>. Case access is restricted to the creator; public registration always creates the Analyst role.

| Method | Route | Input / behavior |
|---|---|---|
| POST | /api/auth/register | username (3-50), password (12-128); returns token and user |
| POST | /api/auth/login | username/password; returns 60-minute JWT |
| GET | /api/users/me | current account |
| GET / POST | /api/cases | list own cases / create CaseDto |
| GET / PUT / DELETE | /api/cases/{id} | read / replace editable fields / delete empty case |
| GET | /api/cases/{id}/findings | persisted findings |
| POST | /api/osint/phone | caseId, value |
| POST | /api/osint/email | caseId, value |
| POST | /api/osint/username | caseId, value |
| POST | /api/osint/domain | caseId, value |
| POST | /api/osint/ip | caseId, value |
| POST | /api/forensics/cnic | value; does not save the raw CNIC |
| POST | /api/forensics/image | multipart: caseId, file, source; PNG/JPEG |
| POST | /api/evidence | multipart: caseId, file, source; PNG/JPEG/PDF/TXT |
| GET | /api/evidence/{caseId} | evidence metadata |
| GET | /api/evidence/{caseId}/{evidenceId} | verified original bytes as attachment |
| POST | /api/evidence/{caseId}/{evidenceId}/verify | recompute hash, persist status |
| GET | /api/correlation/{caseId} | nodes, membership edges and repeated input hash groups |
| POST | /api/reports/{caseId} | generate PDF, rechecking evidence hashes |
| GET | /api/reports/case/{caseId} | list case reports |
| GET | /api/reports/{id} | authenticated PDF download |
| GET | /health | process liveness only, not database readiness |

CaseDto: title, description (up to 4000), status (Open / In progress / Closed), priority (Normal / High / Critical). Title is 3-160 characters. New cases default to Open / Normal.

OSINT responses contain investigationId, status, findings and notice. Findings expose findingType, value, sourceUrl and confidence. A zero-confidence research lead is not a verified account. Confidence here describes the local observation/lead status; it is not a statistical identity probability.

Errors: 400 invalid input, 401 missing/invalid session, 404 missing or inaccessible resource, 409 duplicate username/non-empty case deletion/integrity mismatch, 413 oversize request, 429 rate limit, 500 sanitized unexpected failure. Errors use ProblemDetails or ASP.NET validation details. Upload limit: 10 MB plus multipart overhead.
