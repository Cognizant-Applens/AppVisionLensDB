CREATE TABLE [AVL].[BOM_ActivityMap] (
    [BOMActivityMapID]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [ActivityID]        BIGINT        NULL,
    [IsActive]          BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    [ApplicationID]     BIGINT        NULL,
    [Manual]            BIT           NULL,
    [BusinessProcessId] INT           NULL,
    [AccountId]         INT           NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_Isactive_accid]
    ON [AVL].[BOM_ActivityMap]([IsActive] ASC, [AccountId] ASC);

