CREATE TABLE [AVL].[APP_MAP_ApplicationProjectMapping] (
    [ProjectApplicationMapID]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]                   BIGINT        NULL,
    [ApplicationID]               BIGINT        NULL,
    [IsDeleted]                   BIT           NOT NULL,
    [CreatedBy]                   NVARCHAR (50) NOT NULL,
    [CreatedDate]                 DATETIME      CONSTRAINT [DF_APP_MAP_ApplicationProjectMapping_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                  NVARCHAR (50) NULL,
    [ModifiedDate]                DATETIME      NULL,
    [MainspringSUPPORTCATEGORYID] BIGINT        NULL,
    [InActivatedDate]             DATETIME      NULL,
    CONSTRAINT [PK_APP_MAP_ApplicationProjectMapping] PRIMARY KEY CLUSTERED ([ProjectApplicationMapID] ASC),
    CONSTRAINT [FK_APP_MAP_ApplicationProjectMapping_APP_MAS_ApplicationDetails] FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    CONSTRAINT [FK_APP_MAP_ApplicationProjectMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_ApplicationProjectMapping_AppId_Isdeleted]
    ON [AVL].[APP_MAP_ApplicationProjectMapping]([ApplicationID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [ApplicationProjectMapping_ProjectID]
    ON [AVL].[APP_MAP_ApplicationProjectMapping]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ApplicationID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_APP_MAP_ApplicationProjectMapping_IsDeleted_ProjectID_ApplicationID]
    ON [AVL].[APP_MAP_ApplicationProjectMapping]([IsDeleted] ASC)
    INCLUDE([ProjectID], [ApplicationID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_ApplicationProjectMapping_ProjectID_ApplicationID_Isdeleted]
    ON [AVL].[APP_MAP_ApplicationProjectMapping]([ProjectID] ASC, [ApplicationID] ASC, [IsDeleted] ASC);

