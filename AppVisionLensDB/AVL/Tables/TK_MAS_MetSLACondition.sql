CREATE TABLE [AVL].[TK_MAS_MetSLACondition] (
    [MetSLAId]     INT           IDENTITY (1, 1) NOT NULL,
    [MetSLAName]   VARCHAR (100) NULL,
    [CreatedBy]    NUMERIC (6)   NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   NUMERIC (6)   NULL,
    [ModifiedDate] DATETIME      NULL,
    [IsDeleted]    BIT           NULL
);

