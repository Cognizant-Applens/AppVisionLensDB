CREATE TYPE [AVL].[SaveTicketDetails] AS TABLE (
    [TicketID]          VARCHAR (100)  NULL,
    [TicketDescription] VARCHAR (4000) NULL,
    [ServiceID]         BIGINT         NULL,
    [ActivityID]        BIGINT         NULL,
    [TicketType]        BIGINT         NULL,
    [TicketStatus]      BIGINT         NULL,
    [ITSMEffort]        DECIMAL (5, 2) NULL,
    [TotalEffort]       DECIMAL (5, 2) NULL,
    [ProjectID]         BIGINT         NULL,
    [TimeTickerID]      BIGINT         NULL,
    [UserID]            BIGINT         NULL,
    [DARTStatusID]      BIGINT         NULL,
    [ApplicationID]     BIGINT         NULL);

