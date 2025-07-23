CREATE TYPE [AVL].[SaveTicketDetails_TS] AS TABLE (
    [TicketID]          VARCHAR (100)   NULL,
    [TicketDescription] NVARCHAR (MAX)  NULL,
    [ServiceID]         BIGINT          NULL,
    [ActivityID]        BIGINT          NULL,
    [TicketType]        BIGINT          NULL,
    [TicketStatus]      BIGINT          NULL,
    [ITSMEffort]        DECIMAL (25, 2) NULL,
    [TotalEffort]       DECIMAL (25, 2) NULL,
    [ProjectID]         BIGINT          NULL,
    [TimeTickerID]      BIGINT          NULL,
    [UserID]            BIGINT          NULL,
    [DARTStatusID]      BIGINT          NULL,
    [ApplicationID]     BIGINT          NULL,
    [Type]              VARCHAR (10)    NULL);

