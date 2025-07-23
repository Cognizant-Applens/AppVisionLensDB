CREATE TABLE [PP].[ScopeOfWork] (
    [ID]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]           BIGINT        NOT NULL,
    [IsApplensAsALM]      BIT           NULL,
    [IsExternalALM]       BIT           NULL,
    [ALMToolID]           INT           NULL,
    [ProjectTypeID]       INT           NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBY]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    [IsSubmit]            BIT           NULL,
    [ALMTimeZoneId]       INT           NULL,
    [ProjectTypeSource]   VARCHAR (250) NULL,
    [ProjectTypeTarget]   VARCHAR (250) NULL,
    [IsTransitionInScope] BIT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([ALMToolID]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    FOREIGN KEY ([ProjectTypeID]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210805-182045]
    ON [PP].[ScopeOfWork]([ProjectID] ASC, [IsDeleted] ASC);

