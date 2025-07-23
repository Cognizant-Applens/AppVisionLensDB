CREATE TABLE [AVL].[TK_TRN_TicketDetail] (
    [TimeTickerID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketID]                     NVARCHAR (50)   NOT NULL,
    [ApplicationID]                BIGINT          NOT NULL,
    [ProjectID]                    BIGINT          NULL,
    [AssignedTo]                   NVARCHAR (100)  NULL,
    [AssignmentGroup]              NVARCHAR (200)  NULL,
    [EffortTillDate]               DECIMAL (25, 2) NOT NULL,
    [ServiceID]                    INT             NOT NULL,
    [TicketDescription]            NVARCHAR (MAX)  NOT NULL,
    [IsDeleted]                    BIT             NOT NULL,
    [CauseCodeMapID]               BIGINT          NULL,
    [DebtClassificationMapID]      BIGINT          NULL,
    [ResidualDebtMapID]            BIGINT          NULL,
    [ResolutionCodeMapID]          BIGINT          NULL,
    [ResolutionMethodMapID]        BIGINT          NULL,
    [KEDBAvailableIndicatorMapID]  BIGINT          NULL,
    [KEDBUpdatedMapID]             BIGINT          NULL,
    [KEDBPath]                     NVARCHAR (250)  NULL,
    [PriorityMapID]                BIGINT          NULL,
    [ReleaseTypeMapID]             BIGINT          CONSTRAINT [DF_TK_TRN_TicketDetail_ReleaseTypeMapID] DEFAULT (NULL) NULL,
    [SeverityMapID]                BIGINT          NULL,
    [TicketSourceMapID]            BIGINT          NULL,
    [TicketStatusMapID]            BIGINT          NULL,
    [TicketTypeMapID]              BIGINT          NULL,
    [BusinessSourceName]           NVARCHAR (50)   NULL,
    [Onsite_Offshore]              NVARCHAR (50)   NULL,
    [PlannedEffort]                DECIMAL (25, 2) NULL,
    [EstimatedWorkSize]            DECIMAL (25, 2) NULL,
    [ActualEffort]                 DECIMAL (25, 2) NULL,
    [ActualWorkSize]               DECIMAL (25, 2) NULL,
    [Resolvedby]                   NVARCHAR (50)   NULL,
    [Closedby]                     NVARCHAR (50)   NULL,
    [ElevateFlagInternal]          INT             NULL,
    [RCAID]                        VARCHAR (50)    NULL,
    [PlannedDuration]              DECIMAL (25, 2) NULL,
    [Actualduration]               DECIMAL (25, 2) NULL,
    [TicketSummary]                NVARCHAR (MAX)  NULL,
    [NatureoftheTicket]            NVARCHAR (50)   NULL,
    [Comments]                     NVARCHAR (1000) NULL,
    [RepeatedIncident]             NVARCHAR (50)   NULL,
    [RelatedTickets]               NVARCHAR (100)  NULL,
    [TicketCreatedBy]              NVARCHAR (4000) NULL,
    [SecondaryResources]           NVARCHAR (50)   NULL,
    [EscalatedFlagCustomer]        NVARCHAR (50)   NULL,
    [ReasonforRejection]           NVARCHAR (1000) NULL,
    [AvoidableFlag]                INT             NULL,
    [ReleaseDate]                  DATETIME        NULL,
    [TicketCreateDate]             DATETIME        NULL,
    [PlannedStartDate]             DATETIME        NULL,
    [PlannedEndDate]               DATETIME        NULL,
    [ActualStartdateTime]          DATETIME        NULL,
    [ActualEnddateTime]            DATETIME        NULL,
    [OpenDateTime]                 DATETIME        NULL,
    [StartedDateTime]              DATETIME        NULL,
    [WIPDateTime]                  DATETIME        NULL,
    [OnHoldDateTime]               DATETIME        NULL,
    [CompletedDateTime]            DATETIME        NULL,
    [ReopenDateTime]               DATETIME        NULL,
    [CancelledDateTime]            DATETIME        NULL,
    [RejectedDateTime]             DATETIME        NULL,
    [Closeddate]                   DATETIME        NULL,
    [AssignedDateTime]             DATETIME        NULL,
    [OutageDuration]               DECIMAL (25, 2) NULL,
    [MetResponseSLAMapID]          INT             NULL,
    [MetAcknowledgementSLAMapID]   INT             NULL,
    [MetResolutionMapID]           INT             NULL,
    [EscalationSLA]                INT             NULL,
    [TKBusinessID]                 BIGINT          NULL,
    [InscopeOutscope]              NVARCHAR (50)   NULL,
    [IsAttributeUpdated]           BIT             NULL,
    [NewStatusDateTime]            DATETIME        NULL,
    [IsSDTicket]                   BIT             NULL,
    [IsManual]                     BIT             NULL,
    [DARTStatusID]                 INT             NULL,
    [ResolutionRemarks]            NVARCHAR (MAX)  NULL,
    [ITSMEffort]                   DECIMAL (25, 2) NULL,
    [CreatedBy]                    NVARCHAR (50)   NOT NULL,
    [CreatedDate]                  DATETIME        NOT NULL,
    [LastUpdatedDate]              DATETIME        NOT NULL,
    [ModifiedBy]                   NVARCHAR (50)   NULL,
    [ModifiedDate]                 DATETIME        NULL,
    [IsApproved]                   BIT             NULL,
    [ReasonResidualMapID]          BIGINT          NULL,
    [ExpectedCompletionDate]       DATETIME        NULL,
    [ApprovedBy]                   NVARCHAR (100)  NULL,
    [DAPId]                        INT             NULL,
    [DebtClassificationMode]       BIGINT          NULL,
    [FlexField1]                   NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_FlexField1] DEFAULT (NULL) NULL,
    [FlexField2]                   NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_FlexField2] DEFAULT (NULL) NULL,
    [FlexField3]                   NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_FlexField3] DEFAULT (NULL) NULL,
    [FlexField4]                   NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_FlexField4] DEFAULT (NULL) NULL,
    [Category]                     NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_Category] DEFAULT (NULL) NULL,
    [Type]                         NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_TicketDetail_Type] DEFAULT (NULL) NULL,
    [AssignmentGroupID]            BIGINT          NULL,
    [LastModifiedSource]           INT             NULL,
    [InitiatedSource]              INT             NULL,
    [IsPartiallyAutomated]         INT             NULL,
    [TicketDescriptionBasePattern] NVARCHAR (250)  NULL,
    [TicketDescriptionSubPattern]  NVARCHAR (250)  NULL,
    [ResolutionRemarksBasePattern] NVARCHAR (250)  NULL,
    [ResolutionRemarksSubPattern]  NVARCHAR (250)  NULL,
    [ServiceClassificationMode]    BIGINT          CONSTRAINT [DK_ServiceClassificationMode] DEFAULT ((3)) NOT NULL,
    CONSTRAINT [PK_TK_TRN_TicketDetails] PRIMARY KEY CLUSTERED ([TimeTickerID] ASC),
    CONSTRAINT [FK_ServiceClassificationMode] FOREIGN KEY ([ServiceClassificationMode]) REFERENCES [MAS].[MachineLearning] ([ID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_APP_MAS_ApplicationDetails] FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAP_CauseCode] FOREIGN KEY ([CauseCodeMapID]) REFERENCES [AVL].[DEBT_MAP_CauseCode] ([CauseID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAP_ResolutionCode] FOREIGN KEY ([ResolutionCodeMapID]) REFERENCES [AVL].[DEBT_MAP_ResolutionCode] ([ResolutionID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAS_DebtClassification] FOREIGN KEY ([DebtClassificationMapID]) REFERENCES [AVL].[DEBT_MAS_DebtClassification] ([DebtClassificationID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAS_ResidualDebt] FOREIGN KEY ([ResidualDebtMapID]) REFERENCES [AVL].[DEBT_MAS_ResidualDebt] ([ResidualDebtID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_PriorityMapping] FOREIGN KEY ([PriorityMapID]) REFERENCES [AVL].[TK_MAP_PriorityMapping] ([PriorityIDMapID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_SeverityMapping] FOREIGN KEY ([SeverityMapID]) REFERENCES [AVL].[TK_MAP_SeverityMapping] ([SeverityIDMapID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_SourceMapping] FOREIGN KEY ([TicketSourceMapID]) REFERENCES [AVL].[TK_MAP_SourceMapping] ([SourceIDMapID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_TicketTypeMapping] FOREIGN KEY ([TicketTypeMapID]) REFERENCES [AVL].[TK_MAP_TicketTypeMapping] ([TicketTypeMappingID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_Business] FOREIGN KEY ([TKBusinessID]) REFERENCES [AVL].[TK_MAS_Business] ([TKBusinessID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_KEDBAvailableIndicator] FOREIGN KEY ([KEDBAvailableIndicatorMapID]) REFERENCES [AVL].[TK_MAS_KEDBAvailableIndicator] ([KEDBAvailableIndicatorID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_KEDBUpdated] FOREIGN KEY ([KEDBUpdatedMapID]) REFERENCES [AVL].[TK_MAS_KEDBUpdated] ([KEDBUpdatedID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_ReleaseType] FOREIGN KEY ([ReleaseTypeMapID]) REFERENCES [AVL].[TK_MAS_ReleaseType] ([ReleaseTypeID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_TRN_TicketDetail] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_TK_TRN_TicketDetail_TK_TRN_TicketDetail1] FOREIGN KEY ([TicketStatusMapID]) REFERENCES [AVL].[TK_MAP_ProjectStatusMapping] ([StatusID]),
    CONSTRAINT [Composite_TicketID_ProjectID] UNIQUE NONCLUSTERED ([TicketID] ASC, [ProjectID] ASC)
);


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_APP_MAS_ApplicationDetails];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAP_CauseCode];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAP_ResolutionCode];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAS_DebtClassification];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_DEBT_MAS_ResidualDebt];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_PriorityMapping];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_SeverityMapping];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_SourceMapping];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAP_TicketTypeMapping];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_Business];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_KEDBAvailableIndicator];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_KEDBUpdated];


GO
ALTER TABLE [AVL].[TK_TRN_TicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_TicketDetail_TK_MAS_ReleaseType];


GO
CREATE NONCLUSTERED INDEX [Composite_TicketID_ProjectID_TimeTickerID]
    ON [AVL].[TK_TRN_TicketDetail]([TicketID] ASC, [ProjectID] ASC, [TimeTickerID] ASC);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex8]
    ON [AVL].[TK_TRN_TicketDetail]([Closeddate] ASC)
    INCLUDE([ProjectID], [AssignedTo]);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex9]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID]);


GO
CREATE NONCLUSTERED INDEX [IDX_ProjectID_OpenDateTime]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC, [OpenDateTime] ASC)
    INCLUDE([TicketID], [ApplicationID], [AssignedTo], [EffortTillDate], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [IDX_TK_Details_OpenDateTime_TicketID_AppID_ProjID_AssignedTo]
    ON [AVL].[TK_TRN_TicketDetail]([OpenDateTime] ASC)
    INCLUDE([TicketID], [ApplicationID], [ProjectID], [AssignedTo], [EffortTillDate], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_TRN_TicketDetail_ProjectID_AssignedTo]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC, [AssignedTo] ASC, [ApplicationID] ASC, [TimeTickerID] ASC, [OpenDateTime] ASC, [DARTStatusID] ASC, [EffortTillDate] ASC)
    INCLUDE([TicketID], [Closeddate], [CompletedDateTime]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_TRN_TicketDetail_ProjectID_AssignmentGroupID]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC, [ApplicationID] ASC, [AssignmentGroupID] ASC, [TimeTickerID] ASC, [OpenDateTime] ASC, [DARTStatusID] ASC, [EffortTillDate] ASC)
    INCLUDE([TicketID], [Closeddate], [CompletedDateTime], [AssignedTo]);


GO
CREATE NONCLUSTERED INDEX [NC_TRN_TicketDetail_Assign_Isdeleted]
    ON [AVL].[TK_TRN_TicketDetail]([AssignedTo] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [ApplicationID], [ProjectID], [AssignmentGroup], [ServiceID], [TicketDescription], [PriorityMapID], [TicketStatusMapID], [TicketTypeMapID], [PlannedEndDate], [OpenDateTime], [IsSDTicket], [IsManual], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [NC_TRN_TicketDetail_Project]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC)
    INCLUDE([TicketID], [ApplicationID], [AssignedTo], [AssignmentGroup], [EffortTillDate], [ServiceID], [TicketDescription], [IsDeleted], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [ResolutionMethodMapID], [KEDBAvailableIndicatorMapID], [KEDBUpdatedMapID], [KEDBPath], [PriorityMapID], [ReleaseTypeMapID], [SeverityMapID], [TicketSourceMapID], [TicketStatusMapID], [TicketTypeMapID], [BusinessSourceName], [Onsite_Offshore], [PlannedEffort], [EstimatedWorkSize], [ActualEffort], [ActualWorkSize], [Resolvedby], [Closedby], [ElevateFlagInternal], [RCAID], [PlannedDuration], [Actualduration], [TicketSummary], [NatureoftheTicket], [Comments], [RepeatedIncident], [RelatedTickets], [TicketCreatedBy], [SecondaryResources], [EscalatedFlagCustomer], [ReasonforRejection], [AvoidableFlag], [ReleaseDate], [TicketCreateDate], [PlannedStartDate], [PlannedEndDate], [ActualStartdateTime], [ActualEnddateTime], [OpenDateTime], [StartedDateTime], [WIPDateTime], [OnHoldDateTime], [CompletedDateTime], [ReopenDateTime], [CancelledDateTime], [RejectedDateTime], [Closeddate], [AssignedDateTime], [OutageDuration], [MetResponseSLAMapID], [MetAcknowledgementSLAMapID], [MetResolutionMapID], [EscalationSLA], [TKBusinessID], [InscopeOutscope], [IsAttributeUpdated], [NewStatusDateTime], [IsSDTicket], [IsManual], [DARTStatusID], [ResolutionRemarks], [ITSMEffort], [CreatedBy], [CreatedDate], [LastUpdatedDate], [ModifiedBy], [ModifiedDate], [IsApproved], [ReasonResidualMapID], [ExpectedCompletionDate], [ApprovedBy], [DAPId], [DebtClassificationMode], [FlexField1], [FlexField2], [FlexField3], [FlexField4], [Category], [Type], [AssignmentGroupID], [LastModifiedSource], [InitiatedSource], [IsPartiallyAutomated]);


GO
CREATE NONCLUSTERED INDEX [NCI2_TK_TRN_TicketDetail_IsDeleted]
    ON [AVL].[TK_TRN_TicketDetail]([IsDeleted] ASC)
    INCLUDE([TicketID], [ProjectID], [EffortTillDate], [ResidualDebtMapID], [AvoidableFlag]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER22_TK_TRN_TicketDetail_ProjectID_IsDeleted_DARTStatusID_Closeddate]
    ON [AVL].[TK_TRN_TicketDetail]([ProjectID] ASC, [IsDeleted] ASC, [DARTStatusID] ASC, [Closeddate] ASC, [CompletedDateTime] ASC, [LastUpdatedDate] ASC)
    INCLUDE([TicketID], [ApplicationID], [ServiceID], [TicketDescription], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [TicketTypeMapID], [AvoidableFlag], [ResolutionRemarks], [FlexField1], [FlexField2], [FlexField3], [FlexField4], [IsPartiallyAutomated], [DebtClassificationMode], [IsApproved], [EffortTillDate], [ITSMEffort]);


GO
CREATE NONCLUSTERED INDEX [Create_Modify_DateTime_TK_TRN_TicketDetail]
    ON [AVL].[TK_TRN_TicketDetail]([CreatedDate] ASC, [ModifiedDate] ASC);

