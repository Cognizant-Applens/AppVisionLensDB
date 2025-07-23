CREATE TABLE [CS].[Opportunity] (
    [OpportunityId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [OpportunityName]   NVARCHAR (250)  NOT NULL,
    [OpportunityType]   NVARCHAR (10)   NOT NULL,
    [NoOfTeams]         INT             NOT NULL,
    [AssociatesPerTeam] INT             NOT NULL,
    [ESAProjectId]      NVARCHAR (15)   NOT NULL,
    [Description]       NVARCHAR (1000) NOT NULL,
    [NominationCloseOn] DATETIME        NOT NULL,
    [OppStartDate]      DATETIME        NOT NULL,
    [OppEndDate]        DATETIME        NOT NULL,
    [UploadDocument]    NVARCHAR (256)  NOT NULL,
    [StatusId]          INT             NOT NULL,
    [NoOfBids]          INT             NOT NULL,
    [IsDeleted]         BIT             DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)   NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [ModifiedBy]        NVARCHAR (50)   NULL,
    [ModifiedDate]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([OpportunityId] ASC)
);

