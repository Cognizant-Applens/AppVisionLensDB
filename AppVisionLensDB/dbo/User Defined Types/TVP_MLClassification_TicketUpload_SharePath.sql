CREATE TYPE [dbo].[TVP_MLClassification_TicketUpload_SharePath] AS TABLE (
    [EsaProjectID]         BIGINT         NOT NULL,
    [ApplicationID]        BIGINT         NULL,
    [Ticket ID]            VARCHAR (50)   NOT NULL,
    [TicketDescription]    NVARCHAR (MAX) NULL,
    [AdditionalText]       NVARCHAR (MAX) NULL,
    [CauseCodeID]          BIGINT         NULL,
    [ResolutionCodeID]     BIGINT         NULL,
    [DebtClassificationID] BIGINT         NULL,
    [AvoidableID]          BIGINT         NULL,
    [ResidualID]           BIGINT         NULL,
    [RuleID]               BIGINT         NULL);

