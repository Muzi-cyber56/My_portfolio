# Scope
Implemented: analyst registration/login, JWT sessions, owner checks, case CRUD, five OSINT tools, CNIC format validation, image evidence ingestion, EXIF extraction, optional local OCR, evidence verification, correlation graph and PDF reports.

OSINT boundaries:
- Phone: international-format validation; no carrier database, subscriber identity or live location.
- Email: syntax and domain validation plus an ICANN research link; no mailbox-existence or breach lookup.
- Username: GitHub/Reddit profile links for manual review; no automated account-existence or identity claim.
- Domain: IDN normalization, bounded live A/AAAA DNS resolution and registration link.
- IP: syntax/address family, conservative public-address classification and registration link.
- CNIC: shape validation only; no NADRA connection. The raw CNIC is not stored.

Not included: disk imaging, deleted-file recovery, memory forensics, malware detonation, device extraction, legal admissibility certification or private identity datasets.
