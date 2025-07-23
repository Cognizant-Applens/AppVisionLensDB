CREATE TYPE [dbo].[TVP_MLClassification_TicketUpload] AS TABLE (
    [EsaProjectID]         BIGINT       NOT NULL,
    [ApplicationID]        BIGINT       NULL,
    [Ticket ID]            VARCHAR (50) NOT NULL,
    [CauseCodeID]          BIGINT       NULL,
    [ResolutionCodeID]     BIGINT       NULL,
    [DebtClassificationID] BIGINT       NULL,
    [AvoidableFlagID]      BIGINT       NULL,
    [ResidualFlagID]       BIGINT       NULL,
    [RuleID]               BIGINT       NULL,
    [LW_RuleID]            BIGINT       NULL,
    [LW_RuleLevel]         VARCHAR (50) NULL);

