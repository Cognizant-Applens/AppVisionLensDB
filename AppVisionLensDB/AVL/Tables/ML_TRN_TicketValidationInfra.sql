CREATE TABLE [AVL].[ML_TRN_TicketValidationInfra] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]            BIGINT         NOT NULL,
    [TicketID]             NVARCHAR (50)  NULL,
    [TicketDescription]    NVARCHAR (MAX) NULL,
    [TowerID]              BIGINT         NULL,
    [DebtClassificationID] INT            NULL,
    [AvoidableFlagID]      INT            NULL,
    [ResidualDebtID]       INT            NULL,
    [CauseCodeID]          BIGINT         NULL,
    [ResolutionCodeID]     BIGINT         NULL,
    [OptionalFieldProj]    NVARCHAR (MAX) NULL,
    [IsDeleted]            BIT            NULL,
    [CreatedBy]            NVARCHAR (50)  NULL,
    [CreatedDate]          DATETIME       NULL,
    [ModifiedBy]           NVARCHAR (50)  NULL,
    [ModifiedDate]         DATETIME       NULL,
    CONSTRAINT [PK__ML_TRN_T__3214EC276403878F] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER16_ML_TRN_TicketValidationInfra]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC, [DebtClassificationID] ASC, [AvoidableFlagID] ASC, [ResidualDebtID] ASC, [CauseCodeID] ASC, [ResolutionCodeID] ASC)
    INCLUDE([TicketID]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER21_ML_TRN_TicketValidationInfra_ProjectID_TowerID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [TowerID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [TicketDescription], [DebtClassificationID], [AvoidableFlagID], [ResidualDebtID], [CauseCodeID], [ResolutionCodeID], [OptionalFieldProj]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER14_ML_TRN_TicketValidationInfra_ProjectID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [TicketDescription]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER6_ML_TRN_TicketValidationInfra_TicketID]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [TowerID] ASC, [IsDeleted] ASC, [DebtClassificationID] ASC, [AvoidableFlagID] ASC, [ResidualDebtID] ASC, [CauseCodeID] ASC, [ResolutionCodeID] ASC)
    INCLUDE([TicketID]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER5_ML_TRN_TicketValidationInfra_ProjectID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [TowerID], [OptionalFieldProj]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER10_ML_TRN_TicketValidationInfra]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC, [DebtClassificationID] ASC, [AvoidableFlagID] ASC, [ResidualDebtID] ASC, [CauseCodeID] ASC, [ResolutionCodeID] ASC)
    INCLUDE([TicketID], [TicketDescription], [TowerID]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER15_ML_TRN_TicketValidationInfra_ProjectID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [OptionalFieldProj]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER4_ML_TRN_TicketValidationInfra_ProjectID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [TowerID]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER7_ML_TRN_TicketValidationInfra_ProjectID_IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([TicketID], [OptionalFieldProj]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER17_ProjectID_TicketID__IsDeleted]
    ON [AVL].[ML_TRN_TicketValidationInfra]([ProjectID] ASC, [TicketID] ASC, [IsDeleted] ASC)
    INCLUDE([OptionalFieldProj]);

