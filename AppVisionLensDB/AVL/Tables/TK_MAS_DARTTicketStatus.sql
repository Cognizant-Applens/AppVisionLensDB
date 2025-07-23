CREATE TABLE [AVL].[TK_MAS_DARTTicketStatus] (
    [DARTStatusID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [DARTStatusName] NVARCHAR (50) NOT NULL,
    [IsDeleted]      BIT           NOT NULL,
    [CreatedBy]      NVARCHAR (50) NOT NULL,
    [CreatedDate]    DATETIME      CONSTRAINT [DF_TK_MAS_TicketStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    CONSTRAINT [PK_TK_MAS_TicketStatus] PRIMARY KEY CLUSTERED ([DARTStatusID] ASC)
);

