CREATE TABLE [AVL].[Debt_MAS_ReasonforCancellation] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [ReasonforCancellation] VARCHAR (2000) NULL,
    [Message]               VARCHAR (2000) NULL,
    [IsActive]              BIT            NULL,
    [IsDormantScope]        BIT            NULL,
    [CreatedBy]             VARCHAR (50)   NULL,
    [CreatedDate]           DATETIME       NULL,
    CONSTRAINT [PK_Debt_MAS_ReasonforCancellation] PRIMARY KEY CLUSTERED ([Id] ASC)
);

