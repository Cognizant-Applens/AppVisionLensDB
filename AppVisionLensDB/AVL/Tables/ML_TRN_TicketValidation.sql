CREATE TABLE [AVL].[ML_TRN_TicketValidation] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]            INT            NOT NULL,
    [TicketID]             NVARCHAR (255) NULL,
    [TicketDescription]    NVARCHAR (MAX) NULL,
    [ApplicationID]        INT            NULL,
    [DebtClassificationID] INT            NULL,
    [AvoidableFlagID]      INT            NULL,
    [ResidualDebtID]       INT            NULL,
    [CauseCodeID]          INT            NULL,
    [ResolutionCodeID]     INT            NULL,
    [CreatedBy]            NVARCHAR (50)  NULL,
    [CreatedDate]          DATETIME       NULL,
    [ModifiedBy]           NVARCHAR (50)  NULL,
    [ModifiedDate]         DATETIME       NULL,
    [IsDeleted]            BIT            NULL,
    [OptionalFieldProj]    NVARCHAR (MAX) NULL,
    [TicketSourceFrom]     NVARCHAR (50)  CONSTRAINT [DF_ML_TRN_TICKETVALIDATION_TicketSourceFrom] DEFAULT ('ML') NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

