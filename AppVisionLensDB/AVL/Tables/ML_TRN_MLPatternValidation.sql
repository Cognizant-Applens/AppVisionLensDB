CREATE TABLE [AVL].[ML_TRN_MLPatternValidation] (
    [ID]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [InitialLearningID]           INT             NULL,
    [ProjectID]                   BIGINT          NULL,
    [ApplicationID]               BIGINT          NULL,
    [ApplicationTypeID]           INT             NULL,
    [TechnologyID]                INT             NULL,
    [TicketPattern]               NVARCHAR (MAX)  NULL,
    [MLResidualFlagID]            INT             NULL,
    [MLDebtClassificationID]      INT             NULL,
    [MLAvoidableFlagID]           INT             NULL,
    [MLCauseCodeID]               INT             NULL,
    [MLAccuracy]                  DECIMAL (18, 2) NULL,
    [TicketOccurence]             INT             NULL,
    [AnalystResidualFlagID]       INT             NULL,
    [AnalystResolutionCodeID]     INT             NULL,
    [AnalystCauseCodeID]          INT             NULL,
    [AnalystDebtClassificationID] INT             NULL,
    [AnalystAvoidableFlagID]      INT             NULL,
    [SMEComments]                 NVARCHAR (MAX)  NULL,
    [SMEResidualFlagID]           INT             NULL,
    [SMEDebtClassificationID]     INT             NULL,
    [SMEAvoidableFlagID]          INT             NULL,
    [SMECauseCodeID]              INT             NULL,
    [IsApprovedOrMute]            INT             NULL,
    [CreatedBy]                   NVARCHAR (20)   NULL,
    [CreatedDate]                 DATETIME        NULL,
    [ModifiedBy]                  NVARCHAR (20)   NULL,
    [ModifiedDate]                DATETIME        NULL,
    [IsDeleted]                   BIT             NULL,
    [Classifiedby]                NVARCHAR (1000) NULL,
    [SMEResolutionCodeID]         INT             NULL,
    [ReasonForResidual]           INT             NULL,
    [ExpectedCompDate]            DATETIME        NULL,
    [MLResolutionCode]            INT             NULL,
    [subPattern]                  NVARCHAR (MAX)  DEFAULT ('0') NOT NULL,
    [additionalPattern]           NVARCHAR (MAX)  DEFAULT ('0') NOT NULL,
    [additionalSubPattern]        NVARCHAR (MAX)  DEFAULT ('0') NOT NULL,
    [OverridenPatternCount]       INT             NULL,
    [OverridenPatternTotalCount]  INT             NULL,
    [IsMLSignOff]                 INT             DEFAULT ((0)) NULL,
    [ContinuousLearningID]        BIGINT          NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_ML_TRN_MLPatternValidation_ProjectID_Isdeleted]
    ON [AVL].[ML_TRN_MLPatternValidation]([ProjectID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PrjID_IsAprdorMute_IsDeleted]
    ON [AVL].[ML_TRN_MLPatternValidation]([ProjectID] ASC, [IsApprovedOrMute] ASC, [IsDeleted] ASC)
    INCLUDE([additionalPattern]);

