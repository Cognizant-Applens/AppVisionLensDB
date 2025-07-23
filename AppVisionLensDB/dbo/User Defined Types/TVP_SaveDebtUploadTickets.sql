CREATE TYPE [dbo].[TVP_SaveDebtUploadTickets] AS TABLE (
    [TicketId]                   VARCHAR (1000) NULL,
    [TicketDescription]          NVARCHAR (MAX) NULL,
    [ApplicationName]            VARCHAR (500)  NULL,
    [DebtClassification]         VARCHAR (500)  NULL,
    [AvoidableFlag]              VARCHAR (500)  NULL,
    [CauseCode]                  NVARCHAR (500) NULL,
    [ResolutionCode]             NVARCHAR (500) NULL,
    [ResidualDebt]               VARCHAR (500)  NULL,
    [OptionalFieldProj]          NVARCHAR (MAX) NULL,
    [IsTicketSummaryUpdated]     BIT            NULL,
    [IsTicketDescriptionUpdated] BIT            NULL);

