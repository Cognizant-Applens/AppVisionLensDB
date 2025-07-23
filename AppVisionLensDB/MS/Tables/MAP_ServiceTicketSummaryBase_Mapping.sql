CREATE TABLE [MS].[MAP_ServiceTicketSummaryBase_Mapping] (
    [ServiceTicketBaseMapID] INT IDENTITY (1, 1) NOT NULL,
    [ServiceID]              INT NULL,
    [TicketSummaryBaseID]    INT NULL,
    [IsDeleted]              BIT NULL,
    CONSTRAINT [PK_ServiceTicketSummaryBase_Mapping] PRIMARY KEY CLUSTERED ([ServiceTicketBaseMapID] ASC) WITH (FILLFACTOR = 70)
);

