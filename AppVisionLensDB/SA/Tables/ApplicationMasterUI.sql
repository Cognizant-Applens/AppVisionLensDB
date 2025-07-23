CREATE TABLE [SA].[ApplicationMasterUI] (
    [ApplicationId]        BIGINT         DEFAULT ('0') NOT NULL,
    [ApplicationName]      NVARCHAR (100) NOT NULL,
    [ApplicationType]      NVARCHAR (100) NOT NULL,
    [Criticality]          NVARCHAR (100) NOT NULL,
    [BusinessCluster]      NVARCHAR (100) NOT NULL,
    [SubCluster]           NVARCHAR (45)  NOT NULL,
    [TechnologyStack]      NVARCHAR (100) NOT NULL,
    [BusinessOwner]        NVARCHAR (100) NOT NULL,
    [SystemOwner]          NVARCHAR (100) NOT NULL,
    [IncidentAllowedGreen] INT            NOT NULL,
    [InfraAllowedGreen]    INT            NOT NULL,
    [IncidentAllowedAmber] INT            NOT NULL,
    [InfraAllowedAmber]    INT            NOT NULL,
    [Comments]             NVARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([ApplicationId] ASC)
);

