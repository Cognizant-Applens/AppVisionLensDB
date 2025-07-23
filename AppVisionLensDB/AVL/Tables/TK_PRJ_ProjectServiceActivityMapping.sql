CREATE TABLE [AVL].[TK_PRJ_ProjectServiceActivityMapping] (
    [ServProjMapID]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [ServiceMapID]     INT           NOT NULL,
    [ProjectID]        BIGINT        NOT NULL,
    [IsDeleted]        BIT           NULL,
    [CreatedDateTime]  DATETIME      NULL,
    [CreatedBY]        NVARCHAR (50) NULL,
    [ModifiedDateTime] DATETIME      NULL,
    [ModifiedBY]       NVARCHAR (50) NULL,
    [IsHidden]         BIT           NULL,
    [EffectiveDate]    DATETIME      NULL,
    [IsMainspringData] CHAR (1)      NULL,
    CONSTRAINT [pk_ServProjMapID] PRIMARY KEY CLUSTERED ([ServProjMapID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex2]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([ServiceMapID] ASC, [IsDeleted] ASC, [EffectiveDate] ASC)
    INCLUDE([ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IDX_TK_Prj_ServiceActivityMapping]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([IsDeleted] ASC)
    INCLUDE([ServiceMapID], [ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_PRJ_ProjectServiceActivityMapping_IsDeleted_EffectiveDate]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([IsDeleted] ASC, [EffectiveDate] ASC)
    INCLUDE([ServiceMapID], [ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_PRJ_ProjectServiceActivityMapping_ProjectID_IsDeleted_EffectiveDate]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([ProjectID] ASC, [IsDeleted] ASC, [EffectiveDate] ASC)
    INCLUDE([ServiceMapID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_PRJ_ProjectServiceActivityMapping_ServiceMapID_ProjectID_IsDeleted]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([ServiceMapID] ASC, [ProjectID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_TK_PRJ_Proj_IsDeleted]
    ON [AVL].[TK_PRJ_ProjectServiceActivityMapping]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ServiceMapID], [IsHidden]);

