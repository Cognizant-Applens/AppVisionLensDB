CREATE TABLE [AVL].[TK_MAS_Service] (
    [ServiceID]             INT           IDENTITY (1, 1) NOT NULL,
    [ServiceName]           NVARCHAR (50) NULL,
    [ServiceType]           INT           NULL,
    [ServiceLevelID]        INT           NULL,
    [IsDeleted]             BIT           NULL,
    [CreatedBy]             NVARCHAR (50) NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_TK_MAS_Service_CreatedDate] DEFAULT (getdate()) NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [ModifiedDate]          DATETIME      NULL,
    [IsBenchMarkApplicable] BIT           DEFAULT ((0)) NOT NULL,
    [IsRetired]             BIT           DEFAULT ((0)) NOT NULL,
    [RetirementDate]        DATETIME      NULL,
    [MainspringServiceName] NVARCHAR (50) NULL,
    [ScopeID]               SMALLINT      NULL,
    CONSTRAINT [PK_TK_MAS_Service] PRIMARY KEY CLUSTERED ([ServiceID] ASC),
    FOREIGN KEY ([ScopeID]) REFERENCES [MAS].[PPScope] ([ScopeID])
);


GO
CREATE NONCLUSTERED INDEX [NC_TK_MAS_Service_Type]
    ON [AVL].[TK_MAS_Service]([ServiceType] ASC)
    INCLUDE([ServiceID], [ServiceName]);

