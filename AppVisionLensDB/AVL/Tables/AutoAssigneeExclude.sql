CREATE TABLE [AVL].[AutoAssigneeExclude] (
    [TimeTickerID]  BIGINT        NOT NULL,
    [TicketID]      NVARCHAR (50) NOT NULL,
    [CustomerID]    BIGINT        NOT NULL,
    [ProjectID]     BIGINT        NOT NULL,
    [SubmitterId]   NVARCHAR (50) NOT NULL,
    [TimesheetDate] DATE          NOT NULL,
    [StartDate]     DATE          NOT NULL,
    [EndDate]       DATE          NOT NULL,
    [IsDeleted]     BIT           NULL,
    [CreatedDate]   DATE          NULL,
    [CreatedBy]     NVARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex3]
    ON [AVL].[AutoAssigneeExclude]([CustomerID] ASC, [StartDate] ASC, [EndDate] ASC)
    INCLUDE([TimeTickerID], [TicketID], [ProjectID]);

