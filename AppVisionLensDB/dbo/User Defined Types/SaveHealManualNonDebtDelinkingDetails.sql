CREATE TYPE [dbo].[SaveHealManualNonDebtDelinkingDetails] AS TABLE (
    [TicketID]      VARCHAR (50)  NULL,
    [ServiceID]     INT           NULL,
    [ApplicationID] INT           NULL,
    [ActivityName]  VARCHAR (400) NULL,
    [IsChecked]     BIT           NULL);

