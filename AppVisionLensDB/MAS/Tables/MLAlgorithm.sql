CREATE TABLE [MAS].[MLAlgorithm] (
    [AlgorithmId]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [AlgorithmName] NVARCHAR (50) NOT NULL,
    [AlgorithmKey]  NVARCHAR (6)  NOT NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AlgorithmId] ASC)
);

