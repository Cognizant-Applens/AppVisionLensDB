CREATE TABLE [AVL].[TK_PRJ_ServiceProjectMapping] (
    [ServProjMapID]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ServiceMapID]     INT            NOT NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [ServiceID]        INT            NOT NULL,
    [ServiceName]      NVARCHAR (50)  NULL,
    [ServiceShortName] NVARCHAR (50)  NULL,
    [CategoryID]       INT            NOT NULL,
    [CategoryName]     NVARCHAR (100) NULL,
    [ActivityID]       INT            NOT NULL,
    [ActivityName]     NVARCHAR (100) NULL,
    [EffortType]       NVARCHAR (100) NULL,
    [MaintenanceType]  VARCHAR (50)   NULL,
    [ServiceLevelID]   INT            NULL,
    [IsDeleted]        BIT            NULL,
    [CreatedDateTime]  DATETIME       NULL,
    [CreatedBY]        NVARCHAR (50)  NULL,
    [ModifiedDateTime] DATETIME       NULL,
    [ModifiedBY]       NVARCHAR (50)  NULL,
    [ServiceType]      NVARCHAR (50)  NULL,
    [IsHidden]         BIT            NULL,
    [EffectiveDate]    DATETIME       NULL,
    [StdCategoryID]    INT            CONSTRAINT [DF__PRJ_Servi__StdCa__5F492382] DEFAULT ((0)) NULL,
    [Categorization]   NVARCHAR (100) NULL,
    [IsMainspringData] CHAR (1)       NULL,
    CONSTRAINT [PK_ServiceProjectMapping] PRIMARY KEY CLUSTERED ([ServProjMapID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-ProjectID_ServiceID]
    ON [AVL].[TK_PRJ_ServiceProjectMapping]([ProjectID] ASC, [ServiceID] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180810-183121]
    ON [AVL].[TK_PRJ_ServiceProjectMapping]([ProjectID] ASC, [ServiceID] ASC, [IsDeleted] ASC);

