CREATE TABLE [AVL].[InfraTowerProjectMapping] (
    [TowerProjMapId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]      BIGINT        NOT NULL,
    [TowerID]        BIGINT        NOT NULL,
    [IsEnabled]      BIT           NOT NULL,
    [IsDeleted]      BIT           NULL,
    [CreatedBy]      NVARCHAR (50) NULL,
    [CreatedDate]    DATETIME      NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TowerProjMapId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraTowerProjectMapping_TowerID_IsDeleted_IsEnabled_ProjectID]
    ON [AVL].[InfraTowerProjectMapping]([TowerID] ASC, [IsDeleted] ASC, [IsEnabled] ASC, [ProjectID] ASC);

