CREATE TABLE [SA].[ApplicationInfrastructureMasterNew] (
    [ID]                  BIGINT         NULL,
    [ApplicationID]       BIGINT         NULL,
    [VMName]              NVARCHAR (100) NULL,
    [OperatingSystem]     NVARCHAR (100) NULL,
    [ServerConfiguration] NVARCHAR (100) NULL,
    [ServerOwner]         NVARCHAR (100) NULL,
    [LicenseDetails]      NVARCHAR (100) NULL,
    [DatabaseVersion]     NVARCHAR (100) NULL,
    [HostedEnvironmentID] BIGINT         NULL,
    [AppPlatform]         NVARCHAR (100) NULL
);

