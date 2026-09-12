# System architecture
```mermaid
flowchart TD
  Flutter[Flutter mobile / web] -->|REST JSON + JWT| API[ASP.NET Core API]
  API --> Auth[Authentication and ownership checks]
  Auth --> Cases[Case management]
  Cases --> OSINT[Validation / DNS / public research leads]
  Cases --> Forensics[Signature / SHA-256 / EXIF / optional OCR]
  OSINT --> Findings[Investigations and findings]
  Forensics --> Evidence[Evidence records and private files]
  Findings --> SQL[(Microsoft SQL Server)]
  Evidence --> SQL
  SQL --> Graph[Case graph / repeated input hashes]
  SQL --> Reports[PDF report service]
```

Core has no database or ASP.NET dependencies. Infrastructure implements Core interfaces, including case/auth services in the corresponding repository/security files. API controllers expose the routes from the specification plus read/download/verification endpoints needed by the UI.

There is no mobile-to-database connection. Database credentials and JWT signing material stay on the server. Web preview serves only the compiled Flutter output; evidence is never statically served.
