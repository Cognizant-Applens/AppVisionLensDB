CREATE TABLE [AVL].[TRN_TicketingModuleDefaultPage] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [EmployeeID]   NVARCHAR (50) NOT NULL,
    [AccountID]    BIGINT        NOT NULL,
    [PrivilegeID]  INT           NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_TRN_TicketingModuleDefaultPage] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_TRN_TicketingModuleDefaultPage_Customer] FOREIGN KEY ([AccountID]) REFERENCES [AVL].[Customer] ([CustomerID])
);

