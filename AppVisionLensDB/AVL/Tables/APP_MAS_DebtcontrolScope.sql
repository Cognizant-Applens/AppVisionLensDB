CREATE TABLE [AVL].[APP_MAS_DebtcontrolScope] (
    [DebtcontrolScopeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [DebtcontrolScopeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]            BIT           NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_APP_MAS_Debt_control_Scope_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_Debt_control_Scope] PRIMARY KEY CLUSTERED ([DebtcontrolScopeID] ASC)
);

