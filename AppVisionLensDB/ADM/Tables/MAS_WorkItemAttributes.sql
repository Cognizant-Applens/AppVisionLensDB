CREATE TABLE [ADM].[MAS_WorkItemAttributes] (
    [AttributeId]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [AttributeName] VARCHAR (100) NOT NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AttributeId] ASC)
);

