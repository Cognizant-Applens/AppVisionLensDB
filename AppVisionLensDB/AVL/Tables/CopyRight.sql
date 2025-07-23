CREATE TABLE [AVL].[CopyRight] (
    [CopyRightId]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [CopyRight]    NVARCHAR (MAX) NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [ModifiedDate] DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([CopyRightId] ASC)
);

