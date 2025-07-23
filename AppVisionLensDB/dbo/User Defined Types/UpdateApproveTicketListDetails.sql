CREATE TYPE [dbo].[UpdateApproveTicketListDetails] AS TABLE (
    [TicketID]                NVARCHAR (100) NULL,
    [DebtClassificationMapID] INT            NULL,
    [ResolutionCodeMapID]     INT            NULL,
    [CauseCodeMapID]          INT            NULL,
    [ResidualDebtMapID]       INT            NULL,
    [AvoidableFlag]           INT            NULL,
    [AssignedTo]              NVARCHAR (100) NULL,
    [LastUpdatedDate]         DATETIME       NULL);

