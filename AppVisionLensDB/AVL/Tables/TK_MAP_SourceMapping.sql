CREATE TABLE [AVL].[TK_MAP_SourceMapping] (
    [SourceIDMapID]    BIGINT        IDENTITY (100, 1) NOT NULL,
    [SourceID]         BIGINT        NULL,
    [SourceName]       VARCHAR (500) NULL,
    [ProjectID]        BIGINT        NULL,
    [IsDeleted]        CHAR (1)      NULL,
    [CreatedDateTime]  DATETIME      NULL,
    [CreatedBy]        NVARCHAR (50) NULL,
    [ModifiedDateTime] DATETIME      NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [IsFixedSource]    CHAR (1)      CONSTRAINT [DF__TK_MAP_So__IsFix__7167D3BD] DEFAULT ('Y') NULL,
    [IsDefaultSource]  NVARCHAR (50) CONSTRAINT [DF__TK_MAP_So__IsDef__725BF7F6] DEFAULT ('N') NULL,
    [Position]         INT           CONSTRAINT [DF__TK_MAP_So__Posit__73501C2F] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TK_MAP_SourceMapping] PRIMARY KEY CLUSTERED ([SourceIDMapID] ASC),
    CONSTRAINT [FK_TK_MAP_SourceMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_TK_MAP_SourceMapping_TK_MAS_TicketSource] FOREIGN KEY ([SourceID]) REFERENCES [AVL].[TK_MAS_TicketSource] ([TicketSourceID])
);


GO
CREATE NONCLUSTERED INDEX [TK_MAP_SourceMapping_ProjectID_IsDefaultSource]
    ON [AVL].[TK_MAP_SourceMapping]([ProjectID] ASC, [IsDefaultSource] ASC);

