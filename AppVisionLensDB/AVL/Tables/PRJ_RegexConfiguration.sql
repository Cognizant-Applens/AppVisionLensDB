CREATE TABLE [AVL].[PRJ_RegexConfiguration] (
    [RegexConfigID]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]          BIGINT        NOT NULL,
    [ConfigTypeID]       INT           NULL,
    [EffectiveStartDate] DATETIME      NULL,
    [EffectiveEndDate]   DATETIME      NULL,
    [IsDeleted]          BIT           NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    [RegexFieldID]       INT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([RegexConfigID] ASC),
    CONSTRAINT [FK_ConfigTypeId] FOREIGN KEY ([ConfigTypeID]) REFERENCES [MAS].[Regex_Config] ([ID]),
    CONSTRAINT [FK_ProjectRegex] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_RegexFieldId] FOREIGN KEY ([RegexFieldID]) REFERENCES [MAS].[Regex_Config] ([ID])
);

