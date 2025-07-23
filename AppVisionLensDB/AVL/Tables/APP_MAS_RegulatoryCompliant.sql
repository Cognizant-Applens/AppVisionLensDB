CREATE TABLE [AVL].[APP_MAS_RegulatoryCompliant] (
    [RegulatoryCompliantID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [RegulatoryCompliantName] NVARCHAR (50) NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [CreatedBy]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_APP_MAS_Regulatory_Compliant_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_Regulatory_Compliant] PRIMARY KEY CLUSTERED ([RegulatoryCompliantID] ASC)
);

