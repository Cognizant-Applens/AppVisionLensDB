CREATE TABLE [ADM].[ALMApplicationDetails] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [ApplicationID]          BIGINT          NOT NULL,
    [IsRevenue]              BIT             NULL,
    [IsAnySIVendor]          BIT             NULL,
    [FunctionalKnowledge]    BIGINT          NULL,
    [ExecutionMethod]        BIGINT          NULL,
    [OtherExecutionMethod]   NVARCHAR (100)  NULL,
    [SourceCodeAvailability] INT             NULL,
    [OtherRegulatoryBody]    NVARCHAR (100)  NULL,
    [IsAppAvailable]         INT             NULL,
    [AvailabilityPercentage] DECIMAL (18, 2) NULL,
    [IsDeleted]              BIT             NULL,
    [CreatedBy]              NVARCHAR (50)   NOT NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [ModifiedBy]             NVARCHAR (50)   NULL,
    [ModifiedDate]           DATETIME        NULL,
    CONSTRAINT [PK__ALMAppli__3214EC2712D7A07C] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ApplicationId] FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID])
);

