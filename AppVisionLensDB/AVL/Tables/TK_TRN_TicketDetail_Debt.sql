﻿CREATE TABLE [AVL].[TK_TRN_TicketDetail_Debt] (
    [TimeTickerID]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketID]                    NVARCHAR (50)   NOT NULL,
    [ApplicationID]               BIGINT          NOT NULL,
    [ProjectID]                   BIGINT          NULL,
    [AssignedTo]                  NVARCHAR (50)   NOT NULL,
    [AssignmentGroup]             NVARCHAR (200)  NULL,
    [EffortTillDate]              DECIMAL (18, 2) NOT NULL,
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
    [KEDBPath]                    NVARCHAR (50)   NULL,
    [PriorityMapID]               BIGINT          NULL,
    [ReleaseTypeMapID]            BIGINT          NULL,
    [SeverityMapID]               BIGINT          NULL,
    [TicketSourceMapID]           BIGINT          NULL,
    [TicketStatusMapID]           BIGINT          NULL,
    [TicketTypeMapID]             BIGINT          NULL,
    [BusinessSourceName]          NVARCHAR (50)   NULL,
    [Onsite_Offshore]             NVARCHAR (50)   NULL,
    [PlannedEffort]               DECIMAL (10, 2) NULL,
    [EstimatedWorkSize]           DECIMAL (10, 2) NULL,
    [ActualEffort]                DECIMAL (10, 2) NULL,
    [ActualWorkSize]              DECIMAL (10, 2) NULL,
    [Resolvedby]                  NVARCHAR (50)   NULL,
    [Closedby]                    NVARCHAR (50)   NULL,
    [ElevateFlagInternal]         BIT             NULL,
    [RCAID]                       VARCHAR (50)    NULL,
    [PlannedDuration]             DECIMAL (10, 2) NULL,
    [Actualduration]              DECIMAL (10, 2) NULL,
    [TicketSummary]               NVARCHAR (100)  NULL,
    [NatureoftheTicket]           NVARCHAR (50)   NULL,
    [Comments]                    NVARCHAR (50)   NULL,
    [RepeatedIncident]            NVARCHAR (50)   NULL,
    [RelatedTickets]              NVARCHAR (100)  NULL,
    [TicketCreatedBy]             NVARCHAR (50)   NULL,
    [SecondaryResources]          NVARCHAR (50)   NULL,
    [EscalatedFlagCustomer]       NVARCHAR (50)   NULL,
    [ReasonforRejection]          NVARCHAR (100)  NULL,
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
    [OutageDuration]              DECIMAL (10, 2) NULL,
    [MetResponseSLAMapID]         INT             NULL,
    [MetAcknowledgementSLAMapID]  INT             NULL,
    [MetResolutionMapID]          INT             NULL,
    [TKBusinessID]                BIGINT          NULL,
    [InscopeOutscope]             NVARCHAR (50)   NULL,
    [IsAttributeUpdated]          BIT             NULL,
    [NewStatusDateTime]           DATETIME        NULL,
    [IsSDTicket]                  BIT             NULL,
    [IsManual]                    BIT             NULL,
    [DARTStatusID]                INT             NULL,
    [ResolutionRemarks]           NVARCHAR (1000) NULL,
    [CreatedBy]                   NVARCHAR (50)   NOT NULL,
    [CreatedDate]                 DATETIME        NOT NULL,
    [LastUpdatedDate]             DATETIME        NOT NULL,
    [ModifiedBy]                  NVARCHAR (50)   NULL,
    [ModifiedDate]                DATETIME        NULL,
    [IsApproved]                  BIT             NULL,
    [ReasonResidualMapID]         NVARCHAR (1000) NULL,
    [ExpectedCompletionDate]      DATETIME        NULL
);

