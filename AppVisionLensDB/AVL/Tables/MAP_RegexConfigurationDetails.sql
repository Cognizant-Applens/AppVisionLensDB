CREATE TABLE [AVL].[MAP_RegexConfigurationDetails] (
    [ID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [RegexConfigID] BIGINT         NOT NULL,
    [KeywordID]     INT            NOT NULL,
    [ConditionID]   INT            NOT NULL,
    [KeyValues]     NVARCHAR (MAX) NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [Regexkeyvalues_Constraint] CHECK (isjson([KEYVALUES])=(1)),
    CONSTRAINT [FK_ConditionID] FOREIGN KEY ([ConditionID]) REFERENCES [MAS].[Regex_Config] ([ID]),
    CONSTRAINT [FK_KeywordID] FOREIGN KEY ([KeywordID]) REFERENCES [MAS].[Regex_Config] ([ID]),
    CONSTRAINT [FK_RegexConfigID] FOREIGN KEY ([RegexConfigID]) REFERENCES [AVL].[PRJ_RegexConfiguration] ([RegexConfigID])
);

