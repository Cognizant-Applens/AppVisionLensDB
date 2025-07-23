CREATE TABLE [MAS].[ML_RulesMaster] (
    [RuleID]                   BIGINT         NOT NULL,
    [DescWorkPattern]          NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [DescWorkSubPattern]       NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [ResolutionWorkPattern]    NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [ResolutionWorkSubPattern] NVARCHAR (MAX) DEFAULT (NULL) NULL,
    [CauseCode]                NVARCHAR (500) DEFAULT (NULL) NULL,
    [ResolutionCode]           NVARCHAR (500) DEFAULT (NULL) NULL,
    [DebtClassification]       NVARCHAR (50)  DEFAULT (NULL) NULL,
    [AvoidableFlag]            NVARCHAR (50)  DEFAULT (NULL) NULL,
    [ResidualDebt]             NVARCHAR (50)  DEFAULT (NULL) NULL,
    [AutomationFeasibility]    NVARCHAR (50)  DEFAULT (NULL) NULL,
    [AppInfraFlag]             NVARCHAR (50)  DEFAULT (NULL) NULL,
    [IsDeleted]                BIT            NOT NULL,
    [CreatedDate]              DATETIME       NOT NULL,
    [CreatedBy]                NVARCHAR (50)  NOT NULL,
    [ModifiedDate]             DATETIME       NULL,
    [ModifiedBy]               NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([RuleID] ASC)
);

