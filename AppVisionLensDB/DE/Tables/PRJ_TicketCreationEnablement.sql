CREATE TABLE [DE].[PRJ_TicketCreationEnablement] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT        NOT NULL,
    [TicketType]   CHAR (5)      NOT NULL,
    [IsEnabled]    BIT           NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_TicketEnableProjectId] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

