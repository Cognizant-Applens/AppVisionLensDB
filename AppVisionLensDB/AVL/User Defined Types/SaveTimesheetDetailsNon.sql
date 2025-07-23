CREATE TYPE [AVL].[SaveTimesheetDetailsNon] AS TABLE (
    [TicketID]          VARCHAR (100)  NULL,
    [ServiceID]         INT            NULL,
    [ActivityID]        INT            NULL,
    [TicketType]        INT            NULL,
    [TicketStatus]      INT            NULL,
    [ProjectID]         INT            NULL,
    [TimeSheetID]       INT            NULL,
    [TimesheetDetailID] INT            NULL,
    [TimeTickerID]      INT            NULL,
    [IsNonTicket]       BIT            NULL,
    [Hours]             DECIMAL (5, 2) NULL,
    [TimesheetDate]     DATE           NULL,
    [UserID]            INT            NULL,
    [ApplicationID]     INT            NULL,
    [CustomerID]        BIGINT         NULL,
    [TicketDescription] NVARCHAR (MAX) NULL);

