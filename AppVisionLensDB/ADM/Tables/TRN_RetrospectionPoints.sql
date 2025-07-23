CREATE TABLE [ADM].[TRN_RetrospectionPoints] (
    [RetrospectionPointId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [SprintId]             BIGINT         NOT NULL,
    [CategoryId]           INT            NOT NULL,
    [DimensionId]          INT            NOT NULL,
    [Description]          NVARCHAR (250) NULL,
    [Isdeleted]            BIT            NOT NULL,
    [CreatedBy]            NVARCHAR (50)  NOT NULL,
    [CreatedOn]            DATETIME       NOT NULL,
    [ModifiedBy]           NVARCHAR (50)  NULL,
    [ModifiedOn]           DATETIME       NULL,
    CONSTRAINT [PK_TRN_RetrospectionPoints] PRIMARY KEY CLUSTERED ([RetrospectionPointId] ASC),
    FOREIGN KEY ([CategoryId]) REFERENCES [MAS].[RetrospectionCategory] ([CategoryId]),
    FOREIGN KEY ([DimensionId]) REFERENCES [MAS].[RetrospectionDimension] ([DimensionId]),
    FOREIGN KEY ([SprintId]) REFERENCES [ADM].[ALM_TRN_Sprint_Details] ([SprintDetailsId])
);

