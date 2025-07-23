CREATE TABLE [AVL].[TK_MAS_SolutionType] (
    [SolutionTypeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SolutionTypeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDate]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([SolutionTypeID] ASC)
);

