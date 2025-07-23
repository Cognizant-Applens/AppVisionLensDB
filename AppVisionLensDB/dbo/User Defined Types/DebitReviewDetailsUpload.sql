CREATE TYPE [dbo].[DebitReviewDetailsUpload] AS TABLE (
    [TicketID]                NVARCHAR (100) NULL,
    [DebtClassificationMapID] INT            NULL,
    [ResolutionCodeMapID]     INT            NULL,
    [CauseCodeMapID]          INT            NULL,
    [ResidualDebtMapID]       INT            NULL,
    [AvoidableFlag]           INT            NULL,
    [ReasonResidualMapID]     INT            NULL,
    [ExpectedCompletionDate]  DATETIME       NULL,
    [AssignedTo]              NVARCHAR (100) NULL);

