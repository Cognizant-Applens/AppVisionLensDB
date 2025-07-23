CREATE TABLE [SA].[IncidentTransactionClone] (
    [IncidentNumber]   NVARCHAR (62)   NOT NULL,
    [TicketType]       NVARCHAR (50)   NOT NULL,
    [ShortDescription] NVARCHAR (MAX)  NOT NULL,
    [AssignmentGroup]  NVARCHAR (50)   NULL,
    [BusinessName]     VARCHAR (1)     NOT NULL,
    [Category]         VARCHAR (1)     NOT NULL,
    [ServiceCatalog]   VARCHAR (1)     NOT NULL,
    [Priority]         NVARCHAR (50)   NOT NULL,
    [OpenedOn]         DATETIME        NULL,
    [OpenedBy]         NVARCHAR (50)   NULL,
    [AssignedTo]       NVARCHAR (50)   NOT NULL,
    [SupportRole]      VARCHAR (1)     NOT NULL,
    [IncidentState]    NVARCHAR (50)   NOT NULL,
    [UpdatedOn]        DATETIME        NOT NULL,
    [ClosedOn]         DATETIME        NULL,
    [DurationMinutes]  INT             NOT NULL,
    [ClosedCode]       NVARCHAR (50)   NOT NULL,
    [ClosedNotes]      NVARCHAR (1000) NULL,
    [Technology]       VARCHAR (1)     NOT NULL,
    [ApplicationID]    BIGINT          NOT NULL
);

