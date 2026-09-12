# Limitations
1. OSINT tools are deliberately bounded: phone/email syntax, username leads, DNS and IP registration leads. No subscriber, breach, identity, location or paid provider integration is installed.
2. EXIF is read when present but can be altered or absent. Hashes establish byte consistency, not source truth. Malformed image headers may produce incomplete properties.
3. OCR has a local Tesseract adapter with a 20-second timeout; it requires an installed engine with English language data and a configured absolute executable path. Its output needs analyst review.
4. Correlation shows case membership and equal trimmed/lowercased input hashes, not entity resolution. The visual graph displays the first 12 investigations with the full list below.
5. Reports paginate and escape text, but use a built-in ASCII PDF font. Non-ASCII text is replaced with spaces in PDFs; the original Unicode values remain in SQL Server and the app. For multilingual publication, replace the renderer with a licensed Unicode-capable PDF library and embedded font.
6. Evidence/report storage is local filesystem storage, not immutable WORM or object storage. Audit records are not cryptographically chained. Uploads are not virus scanned.
7. JWT sessions have no refresh token, MFA or server-side logout revocation. Existing tokens expire after 60 minutes. Rate limits are in-process.
8. EnsureCreated handles initial setup only. Production schema upgrades need migrations. Data lists are not paginated and have not been load-tested.
9. Mobile runners are included; native Android/iOS deployment needs platform SDKs, API reachability and certificate configuration. A physical phone cannot use localhost to reach the development computer.
10. This is an implemented development application, not a certified forensic suite or production security audit.
