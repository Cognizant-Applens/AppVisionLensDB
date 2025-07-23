CREATE TABLE [MAS].[MachineLearning] (
    [ID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (200) NOT NULL,
    [Category]    NVARCHAR (200) NOT NULL,
    [IsDeleted]   BIT            NOT NULL,
    [CreatedBy]   NVARCHAR (50)  NULL,
    [CreatedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

