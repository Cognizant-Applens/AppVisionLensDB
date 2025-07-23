CREATE TABLE [AVL].[APP_MAS_ApplicationDetails] (
    [ApplicationID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [ApplicationName]          NVARCHAR (100) NULL,
    [ApplicationCode]          NVARCHAR (50)  NULL,
    [ApplicationShortName]     NVARCHAR (8)   NULL,
    [SubBusinessClusterMapID]  BIGINT         NOT NULL,
    [CodeOwnerShip]            BIGINT         NOT NULL,
    [BusinessCriticalityID]    BIGINT         NOT NULL,
    [PrimaryTechnologyID]      BIGINT         NOT NULL,
    [ApplicationDescription]   NVARCHAR (200) NOT NULL,
    [ProductMarketName]        NVARCHAR (200) NULL,
    [ApplicationCommisionDate] DATETIME       NOT NULL,
    [RegulatoryCompliantID]    BIGINT         NOT NULL,
    [DebtControlScopeID]       BIGINT         NULL,
    [IsActive]                 BIT            NOT NULL,
    [CreatedBy]                NVARCHAR (50)  NOT NULL,
    [CreatedDate]              DATETIME       CONSTRAINT [DF_APP_MAS_ApplicationDetails_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]               NVARCHAR (50)  NULL,
    [ModifiedDate]             DATETIME       NULL,
    [OtherPrimaryTechnology]   NVARCHAR (100) NULL,
    CONSTRAINT [PK_APP_MAS_ApplicationDetails] PRIMARY KEY CLUSTERED ([ApplicationID] ASC),
    CONSTRAINT [FK_APP_MAS_ApplicationDetails_APP_MAS_BusinessCriticality] FOREIGN KEY ([BusinessCriticalityID]) REFERENCES [AVL].[APP_MAS_BusinessCriticality] ([BusinessCriticalityID]),
    CONSTRAINT [FK_APP_MAS_ApplicationDetails_APP_MAS_OwnershipDetails] FOREIGN KEY ([CodeOwnerShip]) REFERENCES [AVL].[APP_MAS_OwnershipDetails] ([ApplicationTypeID]),
    CONSTRAINT [FK_APP_MAS_ApplicationDetails_APP_MAS_PrimaryTechnology] FOREIGN KEY ([PrimaryTechnologyID]) REFERENCES [AVL].[APP_MAS_PrimaryTechnology] ([PrimaryTechnologyID]),
    CONSTRAINT [FK_APP_MAS_ApplicationDetails_APP_MAS_RegulatoryCompliant] FOREIGN KEY ([RegulatoryCompliantID]) REFERENCES [AVL].[APP_MAS_RegulatoryCompliant] ([RegulatoryCompliantID]),
    CONSTRAINT [FK_APP_MAS_ApplicationDetails_BusinessClusterMapping] FOREIGN KEY ([SubBusinessClusterMapID]) REFERENCES [AVL].[BusinessClusterMapping] ([BusinessClusterMapID])
);


GO
CREATE NONCLUSTERED INDEX [ApplicationDetails_BusinessClustermapID]
    ON [AVL].[APP_MAS_ApplicationDetails]([SubBusinessClusterMapID] ASC)
    INCLUDE([ApplicationID], [ApplicationName]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_APP_MAS_ApplicationDetails_IsActive]
    ON [AVL].[APP_MAS_ApplicationDetails]([IsActive] ASC)
    INCLUDE([ApplicationID], [ApplicationName], [SubBusinessClusterMapID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_APP_MAS_ApplicationDetails_SubBusinessClusterMapID]
    ON [AVL].[APP_MAS_ApplicationDetails]([SubBusinessClusterMapID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_APP_MAS_ApplicationDetails_SubBusinessClusterMapID_IsActive_ApplicationName]
    ON [AVL].[APP_MAS_ApplicationDetails]([SubBusinessClusterMapID] ASC, [IsActive] ASC, [ApplicationName] ASC)
    INCLUDE([ApplicationID], [ApplicationCode], [ApplicationShortName], [CodeOwnerShip], [BusinessCriticalityID], [PrimaryTechnologyID], [ApplicationDescription], [ProductMarketName], [ApplicationCommisionDate], [RegulatoryCompliantID], [DebtControlScopeID]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180810-182735]
    ON [AVL].[APP_MAS_ApplicationDetails]([ApplicationID] ASC, [IsActive] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_APP_MAS_ApplicationDetails_AppName]
    ON [AVL].[APP_MAS_ApplicationDetails]([ApplicationID] ASC, [ApplicationName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_APP_MAS_ApplicationDetails_ApplicationID_IsActive]
    ON [AVL].[APP_MAS_ApplicationDetails]([ApplicationID] ASC, [IsActive] ASC)
    INCLUDE([ApplicationName], [SubBusinessClusterMapID]);

