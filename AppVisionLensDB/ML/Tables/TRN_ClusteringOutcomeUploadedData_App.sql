CREATE TABLE [ML].[TRN_ClusteringOutcomeUploadedData_App] (
    [ID]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [MLTransactionId]      BIGINT        NOT NULL,
    [ProjectID]            BIGINT        NOT NULL,
    [TicketID]             NVARCHAR (50) NOT NULL,
    [ApplicationID]        BIGINT        NOT NULL,
    [ClusterID_Resolution] INT           NULL,
    [ClusterID_Desc]       INT           NULL,
    [DebtClassificationID] BIGINT        NULL,
    [AvoidableFlagID]      INT           NULL,
    [ResidualDebtID]       BIGINT        NULL,
    [IsActive]             BIT           NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL
);

