CREATE TABLE [ML].[CL_TRN_TicketValidation] (
    [ID]                           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]                    INT            NOT NULL,
    [TicketID]                     NVARCHAR (500) NULL,
    [TicketDescription]            NVARCHAR (MAX) NULL,
    [ApplicationID]                INT            NOT NULL,
    [DebtClassificationID]         INT            NULL,
    [AvoidableFlagID]              INT            NULL,
    [ResidualDebtID]               INT            NULL,
    [CauseCodeID]                  INT            NULL,
    [ResolutionCodeID]             INT            NULL,
    [OptionalFieldProj]            NVARCHAR (MAX) NULL,
    [CreatedBy]                    NVARCHAR (50)  NOT NULL,
    [CreatedDate]                  DATETIME       NOT NULL,
    [ModifiedBy]                   NVARCHAR (50)  NULL,
    [ModifiedDate]                 DATETIME       NULL,
    [IsDeleted]                    BIT            NOT NULL,
    [TicketDescriptionBasePattern] NVARCHAR (500) DEFAULT (NULL) NULL,
    [TicketDescriptionSubPattern]  NVARCHAR (500) DEFAULT (NULL) NULL,
    [ResolutionRemarksBasePattern] NVARCHAR (500) DEFAULT (NULL) NULL,
    [ResolutionRemarksSubPattern]  NVARCHAR (500) DEFAULT (NULL) NULL,
    CONSTRAINT [PK_CLTicketID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

