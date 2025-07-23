CREATE TYPE [dbo].[ReleasePlanList] AS TABLE (
    [ProjectID]       INT            NULL,
    [TicketID]        NVARCHAR (100) NULL,
    [ReleasePlanning] NVARCHAR (MAX) NULL);

