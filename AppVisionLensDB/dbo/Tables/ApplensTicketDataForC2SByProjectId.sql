CREATE TABLE [dbo].[ApplensTicketDataForC2SByProjectId] (
    [ProjectId]         BIGINT          NULL,
    [ServiceId]         BIGINT          NULL,
    [ComplexityId]      BIGINT          NULL,
    [DataDate]          DATE            NULL,
    [DesignationId]     BIGINT          NULL,
    [IsOffshore]        BIT             NULL,
    [ClosedTicketCount] INT             NULL,
    [OpenedTicketCount] INT             NULL,
    [Effort]            DECIMAL (18, 2) NULL,
    [TicketID]          VARCHAR (MAX)   NULL,
    [EffortTillDate]    DECIMAL (18, 2) NULL,
    [OpenDateTime]      DATETIME        NULL,
    [Closeddate]        DATETIME        NULL,
    [Status]            VARCHAR (MAX)   NULL,
    [CompletedDateTime] DATETIME        NULL
);

