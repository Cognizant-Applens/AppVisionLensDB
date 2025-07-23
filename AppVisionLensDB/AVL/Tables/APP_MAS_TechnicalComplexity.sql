CREATE TABLE [AVL].[APP_MAS_TechnicalComplexity] (
    [TechnicalComplexityID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [TechnicalComplexityName] NVARCHAR (50) NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [CreatedBy]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_APP_Technical_Complexity_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    CONSTRAINT [PK_APP_Technical_Complexity] PRIMARY KEY CLUSTERED ([TechnicalComplexityID] ASC)
);

