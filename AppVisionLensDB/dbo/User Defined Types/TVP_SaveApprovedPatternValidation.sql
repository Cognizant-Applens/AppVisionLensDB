CREATE TYPE [dbo].[TVP_SaveApprovedPatternValidation] AS TABLE (
    [ID]                      INT            NOT NULL,
    [TicketPattern]           NVARCHAR (MAX) NULL,
    [SMEComments]             NVARCHAR (500) NULL,
    [SMEResidualFlagID]       NVARCHAR (500) NULL,
    [SMEDebtClassificationID] NVARCHAR (500) NULL,
    [SMEAvoidableFlagID]      NVARCHAR (500) NULL,
    [MLResidualFlagID]        NVARCHAR (500) NULL,
    [MLDebtClassificationID]  NVARCHAR (500) NULL,
    [MLAvoidableFlagID]       NVARCHAR (500) NULL,
    [SMECauseCodeID]          NVARCHAR (MAX) NULL,
    [IsApprovedOrMute]        INT            NULL,
    [OveriddenPatternCount]   INT            NULL,
    [MLAccuracy]              NVARCHAR (500) NULL,
    [TicketOccurence]         INT            NULL);

