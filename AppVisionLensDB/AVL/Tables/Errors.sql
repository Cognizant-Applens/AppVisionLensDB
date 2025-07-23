CREATE TABLE [AVL].[Errors] (
    [ErrorID]          INT            IDENTITY (1, 1) NOT NULL,
    [CustomerID]       BIGINT         NOT NULL,
    [ErrorSource]      NVARCHAR (MAX) NOT NULL,
    [ErrorDescription] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]        VARCHAR (50)   NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    CONSTRAINT [PK__Errors__358565CA123EB7A3] PRIMARY KEY CLUSTERED ([ErrorID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Errors_CreatedDate]
    ON [AVL].[Errors]([CreatedDate] ASC);

