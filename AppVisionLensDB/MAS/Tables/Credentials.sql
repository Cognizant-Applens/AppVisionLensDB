CREATE TABLE [MAS].[Credentials] (
    [ID]           SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Value]        NVARCHAR (500) NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_dbo.Credentials_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    VARCHAR (100)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   VARCHAR (100)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

