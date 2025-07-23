CREATE TABLE [LW].[RuleTransaction] (
    [RecordID]             BIGINT          NOT NULL,
    [RuleID]               BIGINT          NOT NULL,
    [NewRuleReferanceID]   BIGINT          DEFAULT ((0)) NOT NULL,
    [ApplensRuleID]        BIGINT          DEFAULT (NULL) NULL,
    [RuleLevel]            NVARCHAR (50)   DEFAULT (NULL) NULL,
    [ESAProjectID]         NVARCHAR (50)   DEFAULT (NULL) NULL,
    [ESAProjectName]       NVARCHAR (50)   DEFAULT (NULL) NULL,
    [ApplensProjectID]     BIGINT          NULL,
    [AppID]                BIGINT          DEFAULT (NULL) NULL,
    [AppName]              NVARCHAR (100)  DEFAULT (NULL) NULL,
    [AppType]              NVARCHAR (50)   DEFAULT (NULL) NULL,
    [Technology]           NVARCHAR (500)  DEFAULT (NULL) NULL,
    [AccountID]            BIGINT          DEFAULT (NULL) NULL,
    [AccountName]          NVARCHAR (100)  DEFAULT (NULL) NULL,
    [BUID]                 SMALLINT        DEFAULT (NULL) NULL,
    [BUName]               NVARCHAR (100)  DEFAULT (NULL) NULL,
    [CompetencyName]       NVARCHAR (500)  DEFAULT (NULL) NULL,
    [BusinessProcessName]  NVARCHAR (500)  DEFAULT (NULL) NULL,
    [LOB]                  NVARCHAR (500)  DEFAULT (NULL) NULL,
    [AppInfra]             NVARCHAR (20)   DEFAULT (NULL) NULL,
    [RuleStatusInd]        INT             DEFAULT (NULL) NULL,
    [IsOveridden]          INT             DEFAULT ((0)) NOT NULL,
    [IsDeleted]            SMALLINT        NULL,
    [IsMLSignOff]          SMALLINT        NULL,
    [DeliveryOnpremiseInd] NVARCHAR (20)   DEFAULT (NULL) NULL,
    [RuleOccurance]        BIGINT          DEFAULT (NULL) NULL,
    [InitialContinousFlag] NVARCHAR (50)   DEFAULT (NULL) NULL,
    [RuleConfidence]       DECIMAL (10, 2) DEFAULT (NULL) NULL,
    [CreatedDate]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            NVARCHAR (50)   DEFAULT (NULL) NOT NULL,
    [ModifiedDate]         DATETIME        DEFAULT (getdate()) NULL,
    [ModifiedBy]           NVARCHAR (50)   DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([RecordID] ASC),
    CONSTRAINT [DelTransFK] FOREIGN KEY ([RuleID]) REFERENCES [MAS].[ML_RulesMaster] ([RuleID])
);


GO
CREATE NONCLUSTERED INDEX [INDX_RuleLvl_ISOVERIDDEN_CREATED_DATE_RULE_STATUS_IND]
    ON [LW].[RuleTransaction]([RuleLevel] ASC, [AccountID] ASC, [BUID] ASC, [RuleStatusInd] ASC, [DeliveryOnpremiseInd] ASC, [CreatedDate] ASC, [IsOveridden] ASC, [NewRuleReferanceID] ASC)
    INCLUDE([RecordID], [RuleID], [AccountName], [BUName]);


GO
CREATE NONCLUSTERED INDEX [INDX_CREATED_DEL_ONPREM]
    ON [LW].[RuleTransaction]([CreatedDate] ASC, [DeliveryOnpremiseInd] ASC)
    INCLUDE([RecordID], [RuleStatusInd], [IsOveridden]);


GO
CREATE NONCLUSTERED INDEX [INDX_NewRule_ISOVER]
    ON [LW].[RuleTransaction]([NewRuleReferanceID] ASC, [IsOveridden] ASC)
    INCLUDE([RecordID]);

