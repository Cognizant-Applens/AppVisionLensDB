CREATE TABLE [AVL].[MAS_DebtModeSource] (
    [ID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [Source]      NVARCHAR (MAX) NOT NULL,
    [CreatedBy]   NVARCHAR (50)  NULL,
    [CreatedDate] DATETIME       NULL,
    [IsDeleted]   BIT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

