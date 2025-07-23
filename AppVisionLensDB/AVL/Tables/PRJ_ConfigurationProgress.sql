CREATE TABLE [AVL].[PRJ_ConfigurationProgress] (
    [Id]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerID]           BIGINT          NOT NULL,
    [ProjectID]            BIGINT          NULL,
    [ScreenID]             NVARCHAR (1000) NULL,
    [ITSMScreenId]         INT             NULL,
    [CompletionPercentage] INT             NULL,
    [IsDeleted]            BIT             NULL,
    [CreatedBy]            NVARCHAR (50)   NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedBy]           NVARCHAR (50)   NULL,
    [ModifiedDate]         DATETIME        NULL,
    [IsSeverity]           BIT             NULL,
    [IsDefaultPriority]    BIT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_PRJ_ConfigurationProgress_CustomerID_CompletionPercentage]
    ON [AVL].[PRJ_ConfigurationProgress]([CustomerID] ASC, [CompletionPercentage] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_PRJ_ConfigurationProgress_ITSMScreenId]
    ON [AVL].[PRJ_ConfigurationProgress]([ITSMScreenId] ASC)
    INCLUDE([ScreenID]);


GO
CREATE NONCLUSTERED INDEX [IX_CONF_PROJ_SCR]
    ON [AVL].[PRJ_ConfigurationProgress]([ITSMScreenId] ASC, [CompletionPercentage] ASC)
    INCLUDE([ProjectID], [ScreenID]);


GO
CREATE NONCLUSTERED INDEX [IX_NCConfigurtionProgess_ProjectID]
    ON [AVL].[PRJ_ConfigurationProgress]([ProjectID] ASC);


GO
CREATE NONCLUSTERED INDEX [NCI_ConfigurationProgress_CustomerID_CompletionPercentage_IsDeleted]
    ON [AVL].[PRJ_ConfigurationProgress]([CustomerID] ASC, [CompletionPercentage] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectID], [ScreenID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_PRJ_ConfigurationProgress_ScreenID_ITSMScreenId]
    ON [AVL].[PRJ_ConfigurationProgress]([ScreenID] ASC, [ITSMScreenId] ASC)
    INCLUDE([ProjectID], [IsDeleted]);

