CREATE TABLE [dbo].[SharepathExcelDeleteDetails] (
    [SharePathId]  SMALLINT        IDENTITY (1, 1) NOT NULL,
    [ModuleName]   NVARCHAR (200)  NOT NULL,
    [PathDetails]  NVARCHAR (1000) NOT NULL,
    [IsDeleted]    BIT             NOT NULL,
    [CreatedBy]    NVARCHAR (50)   NOT NULL,
    [CreatedDate]  DATETIME        NOT NULL,
    [ModifiedBy]   NVARCHAR (50)   NULL,
    [ModifiedDate] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([SharePathId] ASC)
);

