CREATE TABLE [AVL].[MAS_DebtModes] (
    [ID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [Mode]        NVARCHAR (MAX) NOT NULL,
    [CreatedBy]   NVARCHAR (50)  NULL,
    [CreatedDate] DATETIME       NULL,
    [IsDeleted]   BIT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

