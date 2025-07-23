CREATE TYPE [dbo].[TVP_SaveApprovedPatternValidationTemp] AS TABLE (
    [ID]                      INT            NOT NULL,
    [TicketPattern]           NVARCHAR (MAX) NULL,
    [SMEComments]             NVARCHAR (500) NULL,
    [SMEResidualFlagID]       NVARCHAR (500) NULL,
    [SMEDebtClassificationID] NVARCHAR (500) NULL,
    [SMEAvoidableFlagID]      NVARCHAR (500) NULL,
    [SMECauseCodeID]          NVARCHAR (MAX) NULL,
    [SMEResolutionCodeID]     NVARCHAR (500) NULL,
    [ReasonForResidual]       NVARCHAR (500) NULL,
    [ReasonID]                INT            NULL,
    [ExpectedCompDate]        DATETIME       NULL,
    [IsApprovedOrMute]        INT            NULL);

