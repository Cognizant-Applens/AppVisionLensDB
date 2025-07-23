CREATE TABLE [AVL].[Customer] (
    [CustomerID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerName]                 NVARCHAR (160) NOT NULL,
    [BUID]                         BIGINT         NULL,
    [IsCognizant]                  INT            NULL,
    [IsDebtengineEnabled]          BIT            NULL,
    [IsAutomationDashboardEnabled] BIT            NULL,
    [IsHealingDashboard]           BIT            NULL,
    [IsDaily]                      BIT            NULL,
    [IsCategoryConfigured]         BIT            NULL,
    [IsEffortConfigured]           BIT            NULL,
    [TimeZoneId]                   INT            NULL,
    [IsITSMEffortConfigured]       BIT            NULL,
    [IsDeleted]                    BIT            NOT NULL,
    [CreatedBy]                    NVARCHAR (50)  NOT NULL,
    [CreatedDate]                  DATETIME       CONSTRAINT [DF_Customer_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                   NVARCHAR (50)  NULL,
    [ModifiedDate]                 DATETIME       NULL,
    [IsEncryptionEnabled]          BIT            NULL,
    [EffortTrackingMethod]         CHAR (1)       NULL,
    [TicketingFormat]              NVARCHAR (MAX) NULL,
    [IsEffortTrackActivityWise]    BIT            CONSTRAINT [DF__Customer__IsEffo__49BAA06D] DEFAULT (NULL) NULL,
    [SDTicketFormat]               VARCHAR (300)  NULL,
    [ESA_AccountID]                NVARCHAR (50)  NOT NULL,
    [IsNonESAMappingAllowed]       BIT            NULL,
    [ApprovalMail]                 NVARCHAR (5)   NULL,
    [Defaultermail]                NVARCHAR (5)   NULL,
    [TicketCount]                  INT            CONSTRAINT [DF__Customer__Ticket__4A5B5599] DEFAULT ((50)) NULL,
    [BusinessUnitID]               INT            NOT NULL,
    [IsAppEditable]                BIT            NULL,
    [ParentCustomerID]             INT            NULL,
    [SBU1ID]                       INT            NULL,
    [SBU2ID]                       INT            NULL,
    [VerticalID]                   INT            NOT NULL,
    [SubVerticalID]                INT            NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_Customer_BusinessUnit] FOREIGN KEY ([BUID]) REFERENCES [AVL].[BusinessUnit] ([BUID]),
    CONSTRAINT [FK_Customer_MASBusinessUnits] FOREIGN KEY ([BusinessUnitID]) REFERENCES [MAS].[BusinessUnits] ([BusinessUnitID]),
    CONSTRAINT [FK_Customer_ParentCustomers] FOREIGN KEY ([ParentCustomerID]) REFERENCES [MAS].[ParentCustomers] ([ParentCustomerID]),
    CONSTRAINT [FK_Customer_SubBusinessUnits1] FOREIGN KEY ([SBU1ID]) REFERENCES [MAS].[SubBusinessUnits1] ([SBU1ID]),
    CONSTRAINT [FK_Customer_SubBusinessUnits2] FOREIGN KEY ([SBU2ID]) REFERENCES [MAS].[SubBusinessUnits2] ([SBU2ID]),
    CONSTRAINT [FK_Customer_SubVerticals] FOREIGN KEY ([SubVerticalID]) REFERENCES [MAS].[SubVerticals] ([SubVerticalID]),
    CONSTRAINT [FK_Customer_Verticals] FOREIGN KEY ([VerticalID]) REFERENCES [MAS].[Verticals] ([VerticalID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_Customers]
    ON [AVL].[Customer]([IsDeleted] ASC)
    INCLUDE([CustomerName], [ESA_AccountID], [ParentCustomerID], [SBU1ID], [SBU2ID], [VerticalID], [SubVerticalID]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180814-100405]
    ON [AVL].[Customer]([CustomerID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180814-100435]
    ON [AVL].[Customer]([CustomerID] ASC, [IsCognizant] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Customer_IsDeleted_BUID]
    ON [AVL].[Customer]([IsDeleted] ASC)
    INCLUDE([BUID]);


GO
CREATE NONCLUSTERED INDEX [NIX_Customer_CustomerID_IsDeleted]
    ON [AVL].[Customer]([BUID] ASC)
    INCLUDE([CustomerID], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [NIX_Customer_IsCognizant]
    ON [AVL].[Customer]([IsCognizant] ASC, [CustomerID] ASC, [IsITSMEffortConfigured] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IsDeleted]
    ON [AVL].[Customer]([IsDeleted] ASC)
    INCLUDE([CustomerID], [ESA_AccountID]);

