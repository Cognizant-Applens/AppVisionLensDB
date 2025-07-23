CREATE TABLE [MAS].[ClusterCategory] (
    [CategoryID]   INT           IDENTITY (1, 1) NOT NULL,
    [CategoryName] VARCHAR (500) NOT NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedBy]    INT           NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   INT           NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

