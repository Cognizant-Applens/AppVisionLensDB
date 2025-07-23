CREATE TABLE [MAS].[PPHorizontal] (
    [HorizontalID]   BIGINT         NOT NULL,
    [HorizontalName] NVARCHAR (250) NULL,
    [Status]         NVARCHAR (50)  NULL,
    [Effectivedate]  DATETIME       NOT NULL,
    [CreatedBy]      NVARCHAR (50)  NOT NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([HorizontalID] ASC)
);

