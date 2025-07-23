CREATE TABLE [AVL].[TK_MAS_TicketType] (
    [TicketTypeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [TicketTypeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]      BIT           NOT NULL,
    [CreatedBy]      NVARCHAR (50) NOT NULL,
    [CreatedDate]    DATETIME      CONSTRAINT [DF_TK_MAS_TicketType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    [SupportTypeId]  INT           NULL,
    CONSTRAINT [PK_TK_MAS_TicketType] PRIMARY KEY CLUSTERED ([TicketTypeID] ASC)
);

