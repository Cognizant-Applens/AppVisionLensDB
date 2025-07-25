﻿CREATE TYPE [AVL].[TVP_TicketAttributeDetails] AS TABLE (
    [TicketID]               VARCHAR (100)   NULL,
    [serviceid]              INT             NULL,
    [projectId]              BIGINT          NULL,
    [Priority]               BIGINT          NULL,
    [Severity]               BIGINT          NULL,
    [Assignedto]             VARCHAR (100)   NULL,
    [ReleaseType]            BIGINT          NULL,
    [EstimatedWorkSize]      DECIMAL (20, 2) NULL,
    [Ticketcreatedate]       DATETIME        NULL,
    [ActualStartdateTime]    DATETIME        NULL,
    [ActualEnddateTime]      DATETIME        NULL,
    [ReopenDate]             DATETIME        NULL,
    [CloseDate]              DATETIME        NULL,
    [KEDBAvailableIndicator] BIGINT          NULL,
    [KEDBUpdatedAdded]       BIGINT          NULL,
    [MetResponseSLA]         VARCHAR (100)   NULL,
    [MetResolution]          VARCHAR (100)   NULL,
    [TicketDescription]      NVARCHAR (MAX)  NULL,
    [Application]            BIGINT          NULL,
    [KEDBPath]               VARCHAR (MAX)   NULL,
    [CompletedDateTime]      DATETIME        NULL,
    [ResolutionCode]         BIGINT          NULL,
    [DebtClassificationId]   BIGINT          NULL,
    [Resolutionmethod]       NVARCHAR (MAX)  NULL,
    [CauseCode]              BIGINT          NULL,
    [TicketOpenDate]         DATETIME        NULL,
    [ActualEffort]           DECIMAL (20, 2) NULL,
    [Comments]               NVARCHAR (MAX)  NULL,
    [PlannedEffort]          DECIMAL (20, 2) NULL,
    [PlannedEndDate]         DATETIME        NULL,
    [PlannedStartDate]       DATETIME        NULL,
    [RCAID]                  NVARCHAR (100)  NULL,
    [ReleaseDate]            DATETIME        NULL,
    [TicketSummary]          NVARCHAR (MAX)  NULL,
    [AvoidableFlag]          INT             NULL,
    [ResidualDebtId]         INT             NULL,
    [TicketSource]           BIGINT          NULL,
    [FlexField1]             NVARCHAR (MAX)  NULL,
    [FlexField2]             NVARCHAR (MAX)  NULL,
    [FlexField3]             NVARCHAR (MAX)  NULL,
    [FlexField4]             NVARCHAR (MAX)  NULL,
    [IsPartiallyAutomated]   INT             NULL,
    [AHBusinessImpact]       SMALLINT        NULL,
    [AHImpactComments]       NVARCHAR (250)  NULL);

