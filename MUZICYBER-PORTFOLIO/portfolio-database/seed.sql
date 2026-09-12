-- Optional, deliberate sample data. Run against OSINTPlatform AFTER schema.sql.
-- Register your account through /api/auth/register first, then set its Id below.
-- No accounts or passwords are seeded.
USE [OSINTPlatform];
GO
DECLARE @OwnerId uniqueidentifier = NULL; -- Replace with your registered user ID.
IF @OwnerId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @OwnerId)
    THROW 50001, 'Set @OwnerId to a registered analyst account before seeding.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.Cases WHERE CaseNumber = N'DEMO-TRAINING-001')
INSERT dbo.Cases (Id, CaseNumber, Title, Description, Status, Priority, CreatedBy, CreatedAt)
VALUES (NEWID(), N'DEMO-TRAINING-001', N'Training investigation',
 N'DEMONSTRATION CASE: synthetic training data only.', N'Open', N'Normal', @OwnerId, SYSDATETIMEOFFSET());
GO
