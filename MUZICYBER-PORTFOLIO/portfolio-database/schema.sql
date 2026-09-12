CREATE TABLE [AuditLogs] (
    [Id] bigint NOT NULL IDENTITY,
    [UserId] uniqueidentifier NULL,
    [Action] nvarchar(max) NOT NULL,
    [Timestamp] datetimeoffset NOT NULL,
    [RequestIp] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_AuditLogs] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Users] (
    [Id] uniqueidentifier NOT NULL,
    [Username] nvarchar(50) NOT NULL,
    [PasswordHash] nvarchar(512) NOT NULL,
    [Role] nvarchar(20) NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Cases] (
    [Id] uniqueidentifier NOT NULL,
    [CaseNumber] nvarchar(40) NOT NULL,
    [Title] nvarchar(160) NOT NULL,
    [Description] nvarchar(4000) NOT NULL,
    [Status] nvarchar(20) NOT NULL,
    [Priority] nvarchar(20) NOT NULL,
    [CreatedBy] uniqueidentifier NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    CONSTRAINT [PK_Cases] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Cases_Users_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION
);
GO


CREATE TABLE [Evidence] (
    [Id] uniqueidentifier NOT NULL,
    [CaseId] uniqueidentifier NOT NULL,
    [EvidenceType] nvarchar(max) NOT NULL,
    [Source] nvarchar(2048) NOT NULL,
    [OriginalName] nvarchar(255) NOT NULL,
    [StoragePath] nvarchar(max) NOT NULL,
    [Sha256] nvarchar(64) NOT NULL,
    [Metadata] nvarchar(max) NOT NULL,
    [CollectedAt] datetimeoffset NOT NULL,
    [IntegrityStatus] nvarchar(max) NOT NULL,
    [LastVerifiedAt] datetimeoffset NULL,
    [Size] bigint NOT NULL,
    CONSTRAINT [PK_Evidence] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Evidence_Cases_CaseId] FOREIGN KEY ([CaseId]) REFERENCES [Cases] ([Id]) ON DELETE NO ACTION
);
GO


CREATE TABLE [Investigations] (
    [Id] uniqueidentifier NOT NULL,
    [CaseId] uniqueidentifier NOT NULL,
    [InputType] nvarchar(30) NOT NULL,
    [InputValueHash] nvarchar(64) NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    CONSTRAINT [PK_Investigations] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Investigations_Cases_CaseId] FOREIGN KEY ([CaseId]) REFERENCES [Cases] ([Id]) ON DELETE NO ACTION
);
GO


CREATE TABLE [Reports] (
    [Id] uniqueidentifier NOT NULL,
    [CaseId] uniqueidentifier NOT NULL,
    [ReportPath] nvarchar(max) NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    CONSTRAINT [PK_Reports] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Reports_Cases_CaseId] FOREIGN KEY ([CaseId]) REFERENCES [Cases] ([Id]) ON DELETE NO ACTION
);
GO


CREATE TABLE [Findings] (
    [Id] uniqueidentifier NOT NULL,
    [InvestigationId] uniqueidentifier NOT NULL,
    [FindingType] nvarchar(80) NOT NULL,
    [Value] nvarchar(max) NOT NULL,
    [SourceUrl] nvarchar(2048) NOT NULL,
    [Confidence] float NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    CONSTRAINT [PK_Findings] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Findings_Investigations_InvestigationId] FOREIGN KEY ([InvestigationId]) REFERENCES [Investigations] ([Id]) ON DELETE NO ACTION
);
GO


CREATE INDEX [IX_AuditLogs_Timestamp] ON [AuditLogs] ([Timestamp]);
GO


CREATE UNIQUE INDEX [IX_Cases_CaseNumber] ON [Cases] ([CaseNumber]);
GO


CREATE INDEX [IX_Cases_CreatedBy] ON [Cases] ([CreatedBy]);
GO


CREATE INDEX [IX_Evidence_CaseId] ON [Evidence] ([CaseId]);
GO


CREATE INDEX [IX_Findings_InvestigationId] ON [Findings] ([InvestigationId]);
GO


CREATE INDEX [IX_Investigations_CaseId] ON [Investigations] ([CaseId]);
GO


CREATE INDEX [IX_Reports_CaseId] ON [Reports] ([CaseId]);
GO


CREATE UNIQUE INDEX [IX_Users_Username] ON [Users] ([Username]);
GO


