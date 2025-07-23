CREATE TABLE [AVL].[APP_MAS_ApplicationStrategy] (
    [ApplicationStrategyID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplicationStrategyName] NVARCHAR (50) NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [CreatedBy]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_APP_MAS_ApplicationStrategy_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_ApplicationStrategy] PRIMARY KEY CLUSTERED ([ApplicationStrategyID] ASC)
);

