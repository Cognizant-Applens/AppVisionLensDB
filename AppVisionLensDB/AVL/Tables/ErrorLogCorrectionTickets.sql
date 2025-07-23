CREATE TABLE [AVL].[ErrorLogCorrectionTickets] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [Ticket ID]            VARCHAR (50)   NOT NULL,
    [Ticket Type]          NVARCHAR (100) NULL,
    [TicketTypeID]         INT            NULL,
    [Assignee]             NVARCHAR (50)  NULL,
    [Modified Date Time]   DATETIME       NULL,
    [Open Date]            DATETIME       NULL,
    [Priority]             NVARCHAR (50)  NULL,
    [PriorityID]           INT            NULL,
    [ResolutionID]         VARCHAR (50)   NULL,
    [Resolution Code]      NVARCHAR (50)  NULL,
    [Status]               NVARCHAR (50)  NULL,
    [StatusID]             INT            NULL,
    [Ticket Description]   NVARCHAR (MAX) NULL,
    [IsManual]             NVARCHAR (10)  NULL,
    [ModifiedBY]           NVARCHAR (10)  NULL,
    [Application]          NVARCHAR (100) NULL,
    [ApplicationID]        INT            NULL,
    [EmployeeID]           NVARCHAR (100) NULL,
    [EmployeeName]         NVARCHAR (100) NULL,
    [External Login ID]    VARCHAR (MAX)  NULL,
    [ProjectID]            INT            NOT NULL,
    [IsDeleted]            CHAR (1)       NULL,
    [Severity]             NVARCHAR (20)  NULL,
    [severityID]           INT            NULL,
    [DebtClassificationId] INT            NULL,
    [Debt Classification]  VARCHAR (100)  NULL,
    [AvoidableFlagID]      INT            NULL,
    [Avoidable Flag]       VARCHAR (100)  NULL,
    [Residual Debt]        VARCHAR (10)   NULL,
    [ResidualDebtID]       INT            NULL,
    [Cause code]           NVARCHAR (50)  NULL,
    [CauseCodeID]          VARCHAR (50)   NULL,
    [SupporttypeID]        INT            DEFAULT ((1)) NULL,
    [TowerID]              BIGINT         NULL,
    [TowerName]            NVARCHAR (200) NULL,
    [Assignment Group ID]  BIGINT         NULL,
    [Assignment Group]     NVARCHAR (200) NULL,
    [IsPartiallyAutomated] NVARCHAR (200) NULL
);


GO
CREATE NONCLUSTERED INDEX [NC_ErrorLogCorrectionTickets_EmployeeID_ProjectID_SupporttypeID]
    ON [AVL].[ErrorLogCorrectionTickets]([EmployeeID] ASC, [ProjectID] ASC, [SupporttypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_ErrorLogCorrectionTickets_EmployeeID_SupporttypeID]
    ON [AVL].[ErrorLogCorrectionTickets]([EmployeeID] ASC, [SupporttypeID] ASC)
    INCLUDE([ProjectID]);


GO
CREATE NONCLUSTERED INDEX [NCI_ErrorLogCorrectionTickets_ProjectID_SupporttypeID]
    ON [AVL].[ErrorLogCorrectionTickets]([ProjectID] ASC, [SupporttypeID] ASC)
    INCLUDE([ID], [Ticket ID], [Ticket Type], [TicketTypeID], [Assignee], [Modified Date Time], [Open Date], [Priority], [PriorityID], [ResolutionID], [Resolution Code], [Status], [StatusID], [Ticket Description], [IsManual], [ModifiedBY], [Application], [ApplicationID], [EmployeeID], [EmployeeName], [External Login ID], [IsDeleted], [Severity], [severityID], [DebtClassificationId], [Debt Classification], [AvoidableFlagID], [Avoidable Flag], [Residual Debt], [ResidualDebtID], [Cause code], [CauseCodeID], [TowerID], [TowerName], [Assignment Group ID], [Assignment Group], [IsPartiallyAutomated]);

