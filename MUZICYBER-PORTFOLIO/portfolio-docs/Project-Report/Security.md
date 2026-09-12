# Security design
- Passwords use PBKDF2-SHA512 with a per-password random salt and 210,000 iterations. Verification uses a constant-time comparison.
- JWT validates signing key, issuer, audience and expiration. A fresh signing key is generated for local setup, kept in ignored appsettings.Local.json. Production must use a secret manager or environment variables.
- Registration creates only Analyst accounts. Case routes require Analyst/Admin and all case services check creator ownership. Admin does not automatically gain access to another owner's evidence.
- Requests are limited to 120/minute per authenticated account or unauthenticated IP. Authentication also has a 10/minute per-IP limit. Limits are per process.
- Entity Framework parameterizes SQL; input never becomes SQL text.
- Evidence accepts a 10 MB maximum and selected extensions with signatures. TXT must be non-null UTF-8. Signature checks are not antivirus scanning or complete format validation.
- Files use generated names outside web roots. Downloads require ownership and verified hashes. EXIF is untrusted metadata; OCR output is untrusted text.
- Audit logs record method, path, status, time, user ID and IP. Passwords, tokens, CNIC values and request bodies are not logged. Audit failures are reported to the server log; auditing is best-effort and not tamper-proof.
- Production uses HTTPS redirection and HSTS. Local HTTP exists for loopback development. Flutter stores tokens through flutter_secure_storage. Web storage has the usual same-origin/XSS exposure limits.
- DNS-only research does not fetch arbitrary target URLs. The app opens curated HTTPS research URLs only when the analyst selects them.

Deployment work: configure TLS, trusted proxies, private database access, backups, least-privilege SQL accounts, monitored audit storage, upload scanning and at-rest protection. Add MFA, account recovery, invite-only provisioning and distributed limits where required. No claim of certified chain of custody is made.
