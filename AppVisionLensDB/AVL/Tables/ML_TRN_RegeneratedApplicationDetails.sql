CREATE TABLE [AVL].[ML_TRN_RegeneratedApplicationDetails] (
    [ID]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [InitialLearningID] INT           NULL,
    [CustomerID]        BIGINT        NULL,
    [ProjectID]         BIGINT        NULL,
    [PortfolioID]       BIGINT        NULL,
    [AppGroupID]        BIGINT        NULL,
    [ApplicationID]     BIGINT        NULL,
    [CreatedBy]         NVARCHAR (20) NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedBy]        NVARCHAR (20) NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IsDeleted]         BIT           NULL,
    [IsMLSignOff]       INT           DEFAULT ((0)) NULL,
    [FromDate]          DATE          NULL,
    [ToDate]            DATE          NULL
);

