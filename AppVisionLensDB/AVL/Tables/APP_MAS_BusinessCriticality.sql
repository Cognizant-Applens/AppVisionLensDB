CREATE TABLE [AVL].[APP_MAS_BusinessCriticality] (
    [BusinessCriticalityID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [BusinessCriticalityName] NVARCHAR (50) NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [CreatedBy]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_APP_MAS_BusinessCriticality_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_BusinessCriticality] PRIMARY KEY CLUSTERED ([BusinessCriticalityID] ASC)
);

