CREATE TABLE [AVL].[TK_MAP_IDGeneration] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]   BIGINT        NULL,
    [NextID]       NUMERIC (8)   NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedBy]    NVARCHAR (50) NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL
);

