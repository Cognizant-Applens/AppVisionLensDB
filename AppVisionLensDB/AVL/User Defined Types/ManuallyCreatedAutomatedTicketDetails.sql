CREATE TYPE [AVL].[ManuallyCreatedAutomatedTicketDetails] AS TABLE (
    [ServiceID]            INT             NULL,
    [ActivityID]           INT             NULL,
    [ActivityName]         NVARCHAR (200)  NULL,
    [ApplicationID]        BIGINT          NULL,
    [NoOfOccurance]        INT             NULL,
    [NoOfAnalystInvolved]  INT             NULL,
    [TotalEfforts]         DECIMAL (18, 2) NULL,
    [ManualNonDebtMinDate] DATE            NULL);

