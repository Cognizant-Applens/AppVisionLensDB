CREATE TABLE [AVL].[AutoAssigneeExcludeInfra] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
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
    [CreatedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]  DATE          NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

