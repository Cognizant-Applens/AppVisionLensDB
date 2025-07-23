CREATE TABLE [AVL].[MAS_ProjectMaster] (
    [ProjectID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [EsaProjectID]               NVARCHAR (50)  NOT NULL,
    [ProjectName]                NVARCHAR (500) NOT NULL,
    [CustomerID]                 BIGINT         NOT NULL,
    [IsESAProject]               CHAR (1)       NOT NULL,
    [IsProjectsetupcompleted]    CHAR (1)       CONSTRAINT [DF__MAS_Proje__IsPro__68D28DBC] DEFAULT ('N') NULL,
    [IsMetricsAutoSubmit]        BIT            NULL,
    [IsMainSpringConfigured]     CHAR (1)       NULL,
    [TicketAttributeIntegartion] INT            NULL,
    [IsDebtEnabled]              CHAR (1)       NULL,
    [IsODCRestricted]            CHAR (1)       NULL,
    [IsDeleted]                  BIT            NOT NULL,
    [IsCoginzant]                NCHAR (10)     NULL,
    [CreateDate]                 DATETIME       NULL,
    [CreatedBY]                  NVARCHAR (50)  NULL,
    [ModifiedDate]               DATETIME       NULL,
    [ModifiedBY]                 NVARCHAR (50)  NULL,
    [ITSMID]                     INT            CONSTRAINT [Default_AVL_MAS_ProjectMaster_ITSMID] DEFAULT (NULL) NULL,
    [ITSMConfiguration]          CHAR (2)       CONSTRAINT [Default_AVL_MAS_ProjectMaster_ITSMConfiguration] DEFAULT (NULL) NULL,
    [IsMigratedFromDART]         INT            NULL,
    [IsMultilingualEnabled]      INT            NULL,
    [MSubscriptionKey]           NVARCHAR (200) NULL,
    [IsSingleORMulti]            INT            NULL,
    [LastUpdateFailureKey]       DATETIME       NULL,
    [HasCCITSMTool]              BIT            CONSTRAINT [df_HashCCITSMTool] DEFAULT (NULL) NULL,
    [HasRCITSMTool]              BIT            CONSTRAINT [df_HasRCITSMTool] DEFAULT (NULL) NULL,
    [ProjectStartDate]           DATETIME       NULL,
    [ProjectEndDate]             DATETIME       NULL,
    [BillType]                   VARCHAR (6)    NULL,
    [AccountManagerID]           NVARCHAR (50)  NULL,
    [ProjectManagerID]           NVARCHAR (50)  NULL,
    [DeliveryManagerID]          NVARCHAR (50)  NULL,
    [ProjectCategory]            NVARCHAR (100) NULL,
    [SubCategory]                NVARCHAR (100) NULL,
    [ProjectOwner]               NVARCHAR (50)  NULL,
    CONSTRAINT [PK_MAS_ProjectMaster] PRIMARY KEY CLUSTERED ([ProjectID] ASC),
    CONSTRAINT [FK_MAS_ProjectMaster_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [AVL].[Customer] ([CustomerID]),
    CONSTRAINT [uni_ESAProjectID_ProjectMaster] UNIQUE NONCLUSTERED ([EsaProjectID] ASC, [IsDeleted] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Projects]
    ON [AVL].[MAS_ProjectMaster]([IsDeleted] ASC)
    INCLUDE([EsaProjectID], [ProjectName], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IX_ProjectMaster_ProjectIDESAID]
    ON [AVL].[MAS_ProjectMaster]([IsDeleted] ASC, [IsMigratedFromDART] ASC)
    INCLUDE([ProjectID], [EsaProjectID], [ProjectName], [IsESAProject]);


GO
CREATE NONCLUSTERED INDEX [IX_PROJECT]
    ON [AVL].[MAS_ProjectMaster]([IsDeleted] ASC)
    INCLUDE([EsaProjectID], [ProjectName], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IDX_custid_isdeleted]
    ON [AVL].[MAS_ProjectMaster]([CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectID], [EsaProjectID], [ProjectName]);


GO
CREATE NONCLUSTERED INDEX [IX_ProjectMaster_EASProject_Project]
    ON [AVL].[MAS_ProjectMaster]([EsaProjectID] ASC, [ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectName]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-ProjectID_CustomerID_IsDeleted]
    ON [AVL].[MAS_ProjectMaster]([ProjectID] ASC, [CustomerID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180810-182923]
    ON [AVL].[MAS_ProjectMaster]([ProjectID] ASC, [CustomerID] ASC, [IsDeleted] ASC, [IsCoginzant] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_ProjectMaster_CustomerID_IsDeleted]
    ON [AVL].[MAS_ProjectMaster]([CustomerID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_EsaProjectID]
    ON [AVL].[MAS_ProjectMaster]([EsaProjectID] ASC)
    INCLUDE([ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IDX_pid_cid]
    ON [AVL].[MAS_ProjectMaster]([ProjectID] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_ProjectMaster_ProjectID_CustomerID_IsDeleted]
    ON [AVL].[MAS_ProjectMaster]([ProjectID] ASC, [CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([IsDebtEnabled], [IsMainSpringConfigured]);


GO
CREATE NONCLUSTERED INDEX [IX_ProjectOnboarding_ESAISDPED]
    ON [AVL].[MAS_ProjectMaster]([IsDeleted] ASC)
    INCLUDE([EsaProjectID], [IsDebtEnabled], [ProjectEndDate]);

