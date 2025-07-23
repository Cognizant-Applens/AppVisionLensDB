CREATE TABLE [AVL].[Debt_BlendedRateCardDetails] (
    [BlendedRateID]     INT             IDENTITY (1, 1) NOT NULL,
    [ProjectId]         INT             NULL,
    [EffectiveFromDate] DATETIME        NULL,
    [EffectiveToDate]   DATETIME        NULL,
    [BlendedRate]       NUMERIC (10, 2) NULL,
    [IsDeleted]         NVARCHAR (10)   NULL,
    [CreatedBy]         NVARCHAR (50)   NULL,
    [CreatedDate]       DATETIME        NULL,
    [IsAppOrInfra]      SMALLINT        CONSTRAINT [DF_Debt_BlendedRateCardDetails_IsAppOrInfra] DEFAULT ((1)) NOT NULL
);

