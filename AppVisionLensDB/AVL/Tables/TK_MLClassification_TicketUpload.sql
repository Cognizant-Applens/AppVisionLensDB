CREATE TABLE [AVL].[TK_MLClassification_TicketUpload] (
    [ID]                       INT            IDENTITY (1, 1) NOT NULL,
    [Ticket ID]                VARCHAR (50)   NOT NULL,
    [ProjectID]                BIGINT         NOT NULL,
    [ApplicationID]            BIGINT         NULL,
    [ApplicationName]          NVARCHAR (100) NULL,
    [Ticket Description]       NVARCHAR (MAX) NULL,
    [Additional Text]          NVARCHAR (MAX) NULL,
    [CauseCodeID]              BIGINT         NULL,
    [Cause code]               NVARCHAR (500) NULL,
    [Resolution Code ID]       BIGINT         NULL,
    [Resolution Code]          NVARCHAR (500) NULL,
    [DebtClassificationId]     BIGINT         NULL,
    [Debt Classification]      VARCHAR (100)  NULL,
    [AvoidableFlagID]          BIGINT         NULL,
    [Avoidable Flag]           VARCHAR (100)  NULL,
    [ResidualDebtID]           BIGINT         NULL,
    [Residual Debt]            VARCHAR (10)   NULL,
    [Rule ID]                  BIGINT         NULL,
    [ISApprover]               INT            NULL,
    [EmployeeID]               NVARCHAR (50)  NULL,
    [ByMLorDD]                 VARCHAR (10)   NULL,
    [TowerID]                  BIGINT         NULL,
    [SupportType]              INT            NULL,
    [DescWorkPattern]          NVARCHAR (500) DEFAULT (NULL) NULL,
    [DescSubWorkPattern]       NVARCHAR (500) DEFAULT (NULL) NULL,
    [ResolutionWorkPattern]    NVARCHAR (500) DEFAULT (NULL) NULL,
    [ResolutionSubWorkPattern] NVARCHAR (500) DEFAULT (NULL) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_PrjID_IsApprover_EmpID]
    ON [AVL].[TK_MLClassification_TicketUpload]([ProjectID] ASC, [ISApprover] ASC, [EmployeeID] ASC)
    INCLUDE([Ticket ID], [ApplicationID], [ApplicationName], [Ticket Description]);

