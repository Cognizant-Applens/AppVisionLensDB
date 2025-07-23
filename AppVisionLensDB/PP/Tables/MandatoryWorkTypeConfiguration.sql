CREATE TABLE [PP].[MandatoryWorkTypeConfiguration] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [ExecutionId]  INT           NOT NULL,
    [WorkTypeId]   BIGINT        NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MandatoryWorkTypeConfiguration_AttributeValueID] FOREIGN KEY ([ExecutionId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    CONSTRAINT [FK_MandatoryWorkTypeConfiguration_WorkTypeId] FOREIGN KEY ([WorkTypeId]) REFERENCES [PP].[ALM_MAS_WorkType] ([WorkTypeId])
);

