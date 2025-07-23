CREATE TABLE [dbo].[ApplensDataForC2SByYear] (
    [ProjectId]         BIGINT          NULL,
    [ServiceId]         BIGINT          NULL,
    [ComplexityId]      BIGINT          NULL,
    [DataDate]          DATE            NULL,
    [DesignationId]     BIGINT          NULL,
    [IsOffshore]        BIT             NULL,
    [ClosedTicketCount] INT             NULL,
    [OpenedTicketCount] INT             NULL,
    [Effort]            DECIMAL (18, 2) NULL
);

