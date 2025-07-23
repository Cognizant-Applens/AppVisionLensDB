CREATE TABLE [CS].[Errors] (
    [ErrorID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [ErrorSource]      NVARCHAR (MAX) NOT NULL,
    [ErrorDescription] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]        VARCHAR (50)   NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([ErrorID] ASC)
);

