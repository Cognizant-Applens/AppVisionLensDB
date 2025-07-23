CREATE TABLE [MAS].[DEBT_AutomatableType] (
    [AutomatableTypeID]   SMALLINT      NOT NULL,
    [AutomatableTypeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]           BIT           NULL,
    [CreatedBy]           NVARCHAR (50) NULL,
    [CreatedDate]         DATETIME      NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AutomatableTypeID] ASC)
);

