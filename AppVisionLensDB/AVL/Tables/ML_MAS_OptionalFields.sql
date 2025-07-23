CREATE TABLE [AVL].[ML_MAS_OptionalFields] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [OptionalFields] NVARCHAR (500) NULL,
    [IsDeleted]      BIT            NULL,
    [CreatedBy]      NVARCHAR (500) NULL,
    [CreatedDate]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

