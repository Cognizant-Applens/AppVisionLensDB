CREATE TYPE [ML].[TVP_Infra_SaveApprovedUploadPatternValidation] AS TABLE (
    [Tower]                       NVARCHAR (MAX) NULL,
    [DescriptionBasePattern]      NVARCHAR (MAX) NULL,
    [DebtClassification]          NVARCHAR (MAX) NULL,
    [ResidualFlag]                NVARCHAR (MAX) NULL,
    [AvoidableFlag]               NVARCHAR (MAX) NULL,
    [CauseCode]                   NVARCHAR (MAX) NULL,
    [MLAccuracy]                  DECIMAL (18)   NULL,
    [TicketOccurence]             INT            NULL,
    [ApprovedOrMute]              NVARCHAR (500) NULL,
    [ResolutionCode]              NVARCHAR (500) NULL,
    [DescriptionSubPattern]       NVARCHAR (500) NULL,
    [ResolutionRemarkBasePattern] NVARCHAR (500) NULL,
    [ResolutionRemarksSubPattern] NVARCHAR (500) NULL);

