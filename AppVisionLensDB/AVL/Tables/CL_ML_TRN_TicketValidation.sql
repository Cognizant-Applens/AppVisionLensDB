CREATE TABLE [AVL].[CL_ML_TRN_TicketValidation] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]            INT            NOT NULL,
    [TicketID]             NVARCHAR (MAX) NULL,
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
    CONSTRAINT [PK_TicketID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

