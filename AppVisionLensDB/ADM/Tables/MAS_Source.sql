CREATE TABLE [ADM].[MAS_Source] (
    [SourceId]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [SourceName]   NVARCHAR (200) NOT NULL,
    [Type]         NVARCHAR (50)  NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_MAS_Source_ADMSourceId] PRIMARY KEY CLUSTERED ([SourceId] ASC)
);

