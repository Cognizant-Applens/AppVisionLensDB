CREATE TABLE [AVL].[BotAutomationMapping] (
    [ID]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]   BIGINT        NOT NULL,
    [BoTTicketID] NVARCHAR (50) NOT NULL,
    [AHTicketID]  NVARCHAR (50) NOT NULL,
    [SupportType] INT           NOT NULL,
    [IsDeleted]   BIT           NOT NULL,
    [CreatedBy]   NVARCHAR (50) NOT NULL,
    [CreatedOn]   DATETIME      NOT NULL,
    [ModifiedBy]  NVARCHAR (50) NULL,
    [ModifiedOn]  DATETIME      NULL,
    CONSTRAINT [PK_BotAutomationMapping] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_BotAutomationMapping]
    ON [AVL].[BotAutomationMapping]([AHTicketID] ASC, [ProjectID] ASC, [IsDeleted] ASC);

