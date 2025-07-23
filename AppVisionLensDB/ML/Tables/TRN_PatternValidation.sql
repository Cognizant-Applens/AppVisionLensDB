CREATE TABLE [ML].[TRN_PatternValidation] (
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
    [ContinuousLearningID]        BIGINT          CONSTRAINT [DF_TRN_PatternValidation_ContinuousLearningID] DEFAULT (NULL) NULL,
    [IsDeleted]                   BIT             NULL,
    [CreatedBy]                   NVARCHAR (20)   NULL,
    [CreatedDate]                 DATETIME        NULL,
    [ModifiedBy]                  NVARCHAR (20)   NULL,
    [ModifiedDate]                DATETIME        NULL,
    [MLOverriddenId]              INT             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID_OverridentPtnCnt_IsDeleted]
    ON [ML].[TRN_PatternValidation]([ProjectID] ASC, [OverridenPatternCount] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NX_Trn_PatternValidation_Id_IsDeleted]
    ON [ML].[TRN_PatternValidation]([ID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketPattern], [subPattern], [additionalPattern], [additionalSubPattern]);

