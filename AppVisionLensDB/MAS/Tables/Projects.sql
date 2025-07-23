CREATE TABLE [MAS].[Projects] (
    [ProjectID]         INT            IDENTITY (1, 1) NOT NULL,
    [ESAProjectID]      NVARCHAR (30)  NOT NULL,
    [ProjectName]       NVARCHAR (500) NOT NULL,
    [ProjectStartDate]  DATETIME       NOT NULL,
    [ProjectEndDate]    DATETIME       NOT NULL,
    [BillType]          VARCHAR (6)    NULL,
    [CustomerID]        INT            NOT NULL,
    [AccountManagerID]  NVARCHAR (50)  NULL,
    [ProjectManagerID]  NVARCHAR (50)  NULL,
    [DeliveryManagerID] NVARCHAR (50)  NULL,
    [ProjectCategory]   NVARCHAR (100) NULL,
    [SubCategory]       NVARCHAR (100) NULL,
    [ProjectOwner]      NVARCHAR (30)  NULL,
    [IsDeleted]         BIT            CONSTRAINT [DF__IsDeleted_Projects] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    CONSTRAINT [PK__Projects] PRIMARY KEY CLUSTERED ([ProjectID] ASC),
    CONSTRAINT [FK__Projects__Customer] FOREIGN KEY ([CustomerID]) REFERENCES [MAS].[Customers] ([CustomerID]),
    CONSTRAINT [UQ__Projects_ESAProjectId] UNIQUE NONCLUSTERED ([ESAProjectID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Projects]
    ON [MAS].[Projects]([IsDeleted] ASC)
    INCLUDE([ESAProjectID], [ProjectName], [CustomerID]);

