CREATE TABLE [LW].[RuleUsage] (
    [TransRecordID] BIGINT        NOT NULL,
    [TimesApplied]  BIGINT        DEFAULT (NULL) NULL,
    [IsDormant]     INT           DEFAULT (NULL) NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedDate]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     NVARCHAR (50) DEFAULT (NULL) NOT NULL,
    [ModifiedDate]  DATETIME      DEFAULT (getdate()) NULL,
    [ModifiedBy]    NVARCHAR (50) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([TransRecordID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IS_DORMANT]
    ON [LW].[RuleUsage]([IsDormant] ASC)
    INCLUDE([TransRecordID]);

