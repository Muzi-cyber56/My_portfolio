# Introduction
Sentinel is a Flutter application for organizing OSINT investigations and digital evidence. The ASP.NET Core API stores case records in Microsoft SQL Server through Entity Framework Core.

The application separates observations from research leads. DNS responses are live observations; generated profile and registration URLs remain unverified until an analyst reviews their sources. The project is intended for authorized research, incident triage and academic demonstrations.

This implementation follows the supplied directory layout. PostgreSQL references in the source specification are superseded by the user's SQL Server requirement. Additional build files, platform runners, shared UI files, scripts and the correlation controller support the requested functionality.
