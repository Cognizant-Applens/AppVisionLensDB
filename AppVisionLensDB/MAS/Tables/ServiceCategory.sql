CREATE TABLE [MAS].[ServiceCategory] (
    [CategoryID]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CategoryName] VARCHAR (50)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

