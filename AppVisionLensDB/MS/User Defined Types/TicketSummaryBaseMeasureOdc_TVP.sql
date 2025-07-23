CREATE TYPE [MS].[TicketSummaryBaseMeasureOdc_TVP] AS TABLE (
    [ServiceID]                   INT           NOT NULL,
    [TicketSummaryBaseMeasureID]  INT           NOT NULL,
    [MainspringPriorityID]        VARCHAR (25)  NULL,
    [MainspringSUPPORTCATEGORYID] VARCHAR (50)  NULL,
    [TicketBaseMeasureValue]      VARCHAR (150) NULL);

