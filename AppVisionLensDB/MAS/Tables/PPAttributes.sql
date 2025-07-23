CREATE TABLE [MAS].[PPAttributes] (
    [AttributeID]      SMALLINT      IDENTITY (1, 1) NOT NULL,
    [AttributeName]    VARCHAR (50)  NOT NULL,
    [SourceID]         SMALLINT      NOT NULL,
    [ScopeID]          SMALLINT      NOT NULL,
    [IsPrepopulate]    BIT           NOT NULL,
    [IsCognizant]      BIT           NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [IsMandatory]      BIT           CONSTRAINT [D_PPAttributes_IsMandatory] DEFAULT ((0)) NOT NULL,
    [IsCopyApplicable] CHAR (2)      NULL,
    PRIMARY KEY CLUSTERED ([AttributeID] ASC),
    FOREIGN KEY ([ScopeID]) REFERENCES [MAS].[PPScope] ([ScopeID]),
    FOREIGN KEY ([SourceID]) REFERENCES [MAS].[PPAttributeSource] ([SourceID])
);

