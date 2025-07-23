CREATE TABLE [dbo].[ApplensTicketDataForC2SByTimePeriod] (
    [EsaProjectId]      BIGINT          NULL,
    [ServiceId]         BIGINT          NULL,
    [DesignationId]     BIGINT          NULL,
    [ComplexityID]      BIGINT          NULL,
    [DataDate]          DATE            NULL,
    [IsOffShore]        BIT             NULL,
    [Effort]            DECIMAL (18, 2) NULL,
    [TicketID]          VARCHAR (MAX)   NULL,
    [EffortTillDate]    DECIMAL (18, 2) NULL,
    [OpenDateTime]      DATETIME        NULL,
    [Closeddate]        DATETIME        NULL,
    [Status]            VARCHAR (MAX)   NULL,
    [CompletedDateTime] DATETIME        NULL
);

