CREATE TABLE [AVL].[CLInDDProjectWiseJobDetails] (
    [ID]                   BIGINT IDENTITY (1, 1) NOT NULL,
    [JobStatusId]          BIGINT NOT NULL,
    [ProjectId]            BIGINT NOT NULL,
    [DDPatternCount]       BIGINT NULL,
    [ConflictPatternCount] BIGINT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

