CREATE TABLE [AVL].[TK_TRN_InfraTicketDetail] (
    [TimeTickerID]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketID]                    NVARCHAR (50)   NOT NULL,
    [TowerID]                     BIGINT          NOT NULL,
    [ProjectID]                   BIGINT          NULL,
    [AssignedTo]                  NVARCHAR (50)   NULL,
    [AssignmentGroup]             NVARCHAR (200)  NULL,
    [EffortTillDate]              DECIMAL (25, 2) NOT NULL,
    [ServiceID]                   INT             NOT NULL,
    [TicketDescription]           NVARCHAR (MAX)  NOT NULL,
    [IsDeleted]                   BIT             NOT NULL,
    [CauseCodeMapID]              BIGINT          NULL,
    [DebtClassificationMapID]     BIGINT          NULL,
    [ResidualDebtMapID]           BIGINT          NULL,
    [ResolutionCodeMapID]         BIGINT          NULL,
    [ResolutionMethodMapID]       BIGINT          NULL,
    [KEDBAvailableIndicatorMapID] BIGINT          NULL,
    [KEDBUpdatedMapID]            BIGINT          NULL,
    [KEDBPath]                    NVARCHAR (250)  NULL,
    [PriorityMapID]               BIGINT          NULL,
    [ReleaseTypeMapID]            BIGINT          CONSTRAINT [DF_TK_TRN_InfraTicketDetail_ReleaseTypeMapID] DEFAULT (NULL) NULL,
    [SeverityMapID]               BIGINT          NULL,
    [TicketSourceMapID]           BIGINT          NULL,
    [TicketStatusMapID]           BIGINT          NULL,
    [TicketTypeMapID]             BIGINT          NULL,
    [BusinessSourceName]          NVARCHAR (50)   NULL,
    [Onsite_Offshore]             NVARCHAR (50)   NULL,
    [PlannedEffort]               DECIMAL (25, 2) NULL,
    [EstimatedWorkSize]           DECIMAL (25, 2) NULL,
    [ActualEffort]                DECIMAL (25, 2) NULL,
    [ActualWorkSize]              DECIMAL (25, 2) NULL,
    [Resolvedby]                  NVARCHAR (50)   NULL,
    [Closedby]                    NVARCHAR (50)   NULL,
    [ElevateFlagInternal]         INT             NULL,
    [RCAID]                       VARCHAR (50)    NULL,
    [PlannedDuration]             DECIMAL (25, 2) NULL,
    [Actualduration]              DECIMAL (25, 2) NULL,
    [TicketSummary]               NVARCHAR (MAX)  NULL,
    [NatureoftheTicket]           NVARCHAR (50)   NULL,
    [Comments]                    NVARCHAR (1000) NULL,
    [RepeatedIncident]            NVARCHAR (50)   NULL,
    [RelatedTickets]              NVARCHAR (100)  NULL,
    [TicketCreatedBy]             NVARCHAR (4000) NULL,
    [SecondaryResources]          NVARCHAR (50)   NULL,
    [EscalatedFlagCustomer]       NVARCHAR (50)   NULL,
    [ReasonforRejection]          NVARCHAR (1000) NULL,
    [AvoidableFlag]               INT             NULL,
    [ReleaseDate]                 DATETIME        NULL,
    [TicketCreateDate]            DATETIME        NULL,
    [PlannedStartDate]            DATETIME        NULL,
    [PlannedEndDate]              DATETIME        NULL,
    [ActualStartdateTime]         DATETIME        NULL,
    [ActualEnddateTime]           DATETIME        NULL,
    [OpenDateTime]                DATETIME        NULL,
    [StartedDateTime]             DATETIME        NULL,
    [WIPDateTime]                 DATETIME        NULL,
    [OnHoldDateTime]              DATETIME        NULL,
    [CompletedDateTime]           DATETIME        NULL,
    [ReopenDateTime]              DATETIME        NULL,
    [CancelledDateTime]           DATETIME        NULL,
    [RejectedDateTime]            DATETIME        NULL,
    [Closeddate]                  DATETIME        NULL,
    [AssignedDateTime]            DATETIME        NULL,
    [OutageDuration]              DECIMAL (25, 2) NULL,
    [MetResponseSLAMapID]         INT             NULL,
    [MetAcknowledgementSLAMapID]  INT             NULL,
    [MetResolutionMapID]          INT             NULL,
    [EscalationSLA]               INT             NULL,
    [TKBusinessID]                BIGINT          NULL,
    [InscopeOutscope]             NVARCHAR (50)   NULL,
    [IsAttributeUpdated]          BIT             NULL,
    [NewStatusDateTime]           DATETIME        NULL,
    [IsSDTicket]                  BIT             NULL,
    [IsManual]                    BIT             NULL,
    [DARTStatusID]                INT             NULL,
    [ResolutionRemarks]           NVARCHAR (MAX)  NULL,
    [ITSMEffort]                  DECIMAL (25, 2) NULL,
    [CreatedBy]                   NVARCHAR (50)   NOT NULL,
    [CreatedDate]                 DATETIME        NOT NULL,
    [LastUpdatedDate]             DATETIME        NOT NULL,
    [ModifiedBy]                  NVARCHAR (50)   NULL,
    [ModifiedDate]                DATETIME        NULL,
    [IsApproved]                  BIT             NULL,
    [ReasonResidualMapID]         BIGINT          NULL,
    [ExpectedCompletionDate]      DATETIME        NULL,
    [ApprovedBy]                  NVARCHAR (100)  NULL,
    [DAPId]                       INT             NULL,
    [DebtClassificationMode]      BIGINT          NULL,
    [FlexField1]                  NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_FlexField1] DEFAULT (NULL) NULL,
    [FlexField2]                  NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_FlexField2] DEFAULT (NULL) NULL,
    [FlexField3]                  NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_FlexField3] DEFAULT (NULL) NULL,
    [FlexField4]                  NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_FlexField4] DEFAULT (NULL) NULL,
    [Category]                    NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_Category] DEFAULT (NULL) NULL,
    [Type]                        NVARCHAR (MAX)  CONSTRAINT [DF_TK_TRN_InfraTicketDetail_Type] DEFAULT (NULL) NULL,
    [AssignmentGroupID]           BIGINT          NULL,
    [LastModifiedSource]          INT             NULL,
    [InitiatedSource]             INT             NULL,
    [IsPartiallyAutomated]        INT             NULL,
    CONSTRAINT [PK_TK_TRN_InfraTicketDetails] PRIMARY KEY CLUSTERED ([TimeTickerID] ASC),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_AVL.InfraTowerDetailsTransaction] FOREIGN KEY ([TowerID]) REFERENCES [AVL].[InfraTowerDetailsTransaction] ([InfraTowerTransactionID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAP_CauseCode] FOREIGN KEY ([CauseCodeMapID]) REFERENCES [AVL].[DEBT_MAP_CauseCode] ([CauseID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAP_ResolutionCode] FOREIGN KEY ([ResolutionCodeMapID]) REFERENCES [AVL].[DEBT_MAP_ResolutionCode] ([ResolutionID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAS_DebtClassification] FOREIGN KEY ([DebtClassificationMapID]) REFERENCES [AVL].[DEBT_MAS_DebtClassification] ([DebtClassificationID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAS_ResidualDebt] FOREIGN KEY ([ResidualDebtMapID]) REFERENCES [AVL].[DEBT_MAS_ResidualDebt] ([ResidualDebtID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_PriorityMapping] FOREIGN KEY ([PriorityMapID]) REFERENCES [AVL].[TK_MAP_PriorityMapping] ([PriorityIDMapID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_SeverityMapping] FOREIGN KEY ([SeverityMapID]) REFERENCES [AVL].[TK_MAP_SeverityMapping] ([SeverityIDMapID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_SourceMapping] FOREIGN KEY ([TicketSourceMapID]) REFERENCES [AVL].[TK_MAP_SourceMapping] ([SourceIDMapID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_TicketTypeMapping] FOREIGN KEY ([TicketTypeMapID]) REFERENCES [AVL].[TK_MAP_TicketTypeMapping] ([TicketTypeMappingID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_Business] FOREIGN KEY ([TKBusinessID]) REFERENCES [AVL].[TK_MAS_Business] ([TKBusinessID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_KEDBAvailableIndicator] FOREIGN KEY ([KEDBAvailableIndicatorMapID]) REFERENCES [AVL].[TK_MAS_KEDBAvailableIndicator] ([KEDBAvailableIndicatorID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_KEDBUpdated] FOREIGN KEY ([KEDBUpdatedMapID]) REFERENCES [AVL].[TK_MAS_KEDBUpdated] ([KEDBUpdatedID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_ReleaseType] FOREIGN KEY ([ReleaseTypeMapID]) REFERENCES [AVL].[TK_MAS_ReleaseType] ([ReleaseTypeID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_TRN_InfraTicketDetail] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_TRN_InfraTicketDetail1] FOREIGN KEY ([TicketStatusMapID]) REFERENCES [AVL].[TK_MAP_ProjectStatusMapping] ([StatusID]),
    CONSTRAINT [Composite_Infra_TicketID_ProjectID] UNIQUE NONCLUSTERED ([TicketID] ASC, [ProjectID] ASC)
);


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_AVL.InfraTowerDetailsTransaction];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAP_CauseCode];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAP_ResolutionCode];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAS_DebtClassification];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_DEBT_MAS_ResidualDebt];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_PriorityMapping];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_SeverityMapping];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_SourceMapping];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAP_TicketTypeMapping];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_Business];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_KEDBAvailableIndicator];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_KEDBUpdated];


GO
ALTER TABLE [AVL].[TK_TRN_InfraTicketDetail] NOCHECK CONSTRAINT [FK_TK_TRN_InfraTicketDetail_TK_MAS_ReleaseType];


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_TRN_InfraTicketDetail_ProjectID_AssignedTo_OpenDateTime]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [AssignedTo] ASC, [OpenDateTime] ASC)
    INCLUDE([TimeTickerID], [TicketID], [TowerID], [EffortTillDate], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_TRN_InfraTicketDetail_OpenDateTime]
    ON [AVL].[TK_TRN_InfraTicketDetail]([OpenDateTime] ASC)
    INCLUDE([TimeTickerID], [TicketID], [TowerID], [ProjectID], [AssignedTo], [EffortTillDate], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_TRN_InfraTicketDetail_LastUpdatedDate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([LastUpdatedDate] ASC)
    INCLUDE([TimeTickerID], [TicketID], [ProjectID], [TicketStatusMapID], [DARTStatusID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_TRN_InfraTicketDetail_DARTStatusID_OpenDateTime_Closeddate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([DARTStatusID] ASC, [OpenDateTime] ASC, [Closeddate] ASC)
    INCLUDE([TimeTickerID], [TicketID], [TowerID], [ProjectID], [AssignedTo], [EffortTillDate], [IsAttributeUpdated]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER3_TK_TRN_InfraTicketDetail_ProjectID_DARTStatusID_Closeddate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [IsDeleted] ASC, [DARTStatusID] ASC, [Closeddate] ASC)
    INCLUDE([TicketID], [TowerID], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [AvoidableFlag]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER8_TK_TRN_InfraTicketDetail_ProjectID_IsDeleted_DARTStatusID_Closeddate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [IsDeleted] ASC, [DARTStatusID] ASC, [Closeddate] ASC)
    INCLUDE([TicketID], [TowerID], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [AvoidableFlag]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER9_TK_TRN_InfraTicketDetail_ProjectID_IsDeleted_DARTStatusID]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [IsDeleted] ASC, [DARTStatusID] ASC)
    INCLUDE([TicketID], [TowerID], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [AvoidableFlag], [Closeddate]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER22_TK_TRN_InfraTicketDetail_ProjectID_IsDeleted_DARTStatusID_Closeddate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [IsDeleted] ASC, [DARTStatusID] ASC, [Closeddate] ASC, [CompletedDateTime] ASC, [LastUpdatedDate] ASC)
    INCLUDE([TicketID], [TowerID], [TicketDescription], [CauseCodeMapID], [DebtClassificationMapID], [ResidualDebtMapID], [ResolutionCodeMapID], [TicketTypeMapID], [AvoidableFlag], [ResolutionRemarks], [FlexField1], [FlexField2], [FlexField3], [FlexField4], [IsPartiallyAutomated], [DebtClassificationMode], [IsApproved], [EffortTillDate], [ITSMEffort]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_TRN_InfraTicketDetail_ProjectID_AssignedTo]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [AssignedTo] ASC, [TowerID] ASC, [TimeTickerID] ASC, [OpenDateTime] ASC, [DARTStatusID] ASC, [EffortTillDate] ASC)
    INCLUDE([TicketID], [Closeddate], [CompletedDateTime]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_TRN_InfraTicketDetail_ProjectID_AssignedTo_TowerID_TimeTickerID_OpenDateTime_DARTStatusID_EffortTillDate]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [AssignedTo] ASC, [TowerID] ASC, [TimeTickerID] ASC, [OpenDateTime] ASC, [DARTStatusID] ASC, [EffortTillDate] ASC)
    INCLUDE([TicketID], [Closeddate], [CompletedDateTime]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_TRN_InfraTicketDetail_ProjectID_TowerID_AssignmentGroupID]
    ON [AVL].[TK_TRN_InfraTicketDetail]([ProjectID] ASC, [TowerID] ASC, [AssignmentGroupID] ASC, [TimeTickerID] ASC, [OpenDateTime] ASC, [DARTStatusID] ASC, [EffortTillDate] ASC)
    INCLUDE([TicketID], [Closeddate], [CompletedDateTime]);

