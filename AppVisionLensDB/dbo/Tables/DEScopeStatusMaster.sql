CREATE TABLE [dbo].[DEScopeStatusMaster] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Status]       VARCHAR (25)  NOT NULL,
    [ISDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

