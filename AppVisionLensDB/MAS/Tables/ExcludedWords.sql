CREATE TABLE [MAS].[ExcludedWords] (
    [ExcludedWordID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ExcludedWordName] NVARCHAR (50) NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDateTime]  DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDateTime] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ExcludedWordID] ASC)
);

