CREATE TABLE [MAS].[RetrospectionDimension] (
    [DimensionId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (50) NOT NULL,
    [Color]       NVARCHAR (50) NOT NULL,
    [Isdeleted]   BIT           NOT NULL,
    [CreatedBy]   NVARCHAR (50) NOT NULL,
    [CreatedOn]   DATETIME      NOT NULL,
    [ModifiedBy]  NVARCHAR (50) NULL,
    [ModifiedOn]  DATETIME      NULL,
    CONSTRAINT [PK_RetrospectionDimension] PRIMARY KEY CLUSTERED ([DimensionId] ASC)
);

