CREATE TABLE [dbo].[C2SWidgetcostdata] (
    [ProjectId]         VARCHAR (50)    NULL,
    [ServiceId]         INT             NULL,
    [ComplexityId]      INT             NULL,
    [DataDate]          DATE            NULL,
    [DesignationId]     INT             NULL,
    [IsOffshore]        BIT             NULL,
    [ClosedTicketCount] INT             NULL,
    [OpenedTicketCount] INT             NULL,
    [Effort]            DECIMAL (10, 2) NULL
);

