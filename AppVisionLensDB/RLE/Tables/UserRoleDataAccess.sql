CREATE TABLE [RLE].[UserRoleDataAccess] (
    [ID]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [RoleMappingID]     BIGINT        NOT NULL,
    [AssociateID]       NVARCHAR (50) NOT NULL,
    [MarketID]          INT           NULL,
    [MarketUnitID]      INT           NULL,
    [BusinessUnitID]    INT           NULL,
    [SBU1ID]            INT           NULL,
    [SBU2ID]            INT           NULL,
    [VerticalID]        INT           NULL,
    [SubVerticalID]     INT           NULL,
    [ParentCustomerID]  INT           NULL,
    [CustomerID]        BIGINT        NULL,
    [ProjectID]         BIGINT        NULL,
    [PracticeID]        INT           NULL,
    [DataSource]        NVARCHAR (10) NOT NULL,
    [ValidTillDate]     DATE          NULL,
    [IsDeleted]         BIT           CONSTRAINT [DF_UserRoleDataAccess_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IndustrySegmentId] INT           NULL,
    CONSTRAINT [PK_UserRoleDataAccess] PRIMARY KEY NONCLUSTERED ([ID] ASC) ON [PRIMARY],
    CONSTRAINT [FK_UserRoleDataAccess_BusinessUnits] FOREIGN KEY ([BusinessUnitID]) REFERENCES [MAS].[BusinessUnits] ([BusinessUnitID]),
    CONSTRAINT [FK_UserRoleDataAccess_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [AVL].[Customer] ([CustomerID]),
    CONSTRAINT [FK_UserRoleDataAccess_IndustrySegments] FOREIGN KEY ([IndustrySegmentId]) REFERENCES [MAS].[IndustrySegments] ([IndustrySegmentId]),
    CONSTRAINT [FK_UserRoleDataAccess_Markets] FOREIGN KEY ([MarketID]) REFERENCES [MAS].[Markets] ([MarketID]),
    CONSTRAINT [FK_UserRoleDataAccess_MarketUnits] FOREIGN KEY ([MarketUnitID]) REFERENCES [MAS].[MarketUnits] ([MarketUnitID]),
    CONSTRAINT [FK_UserRoleDataAccess_ParentCustomers] FOREIGN KEY ([ParentCustomerID]) REFERENCES [MAS].[ParentCustomers] ([ParentCustomerID]),
    CONSTRAINT [FK_UserRoleDataAccess_Practices] FOREIGN KEY ([PracticeID]) REFERENCES [MAS].[Practices] ([PracticeID]),
    CONSTRAINT [FK_UserRoleDataAccess_Projects] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_UserRoleDataAccess_SubBusinessUnits1] FOREIGN KEY ([SBU1ID]) REFERENCES [MAS].[SubBusinessUnits1] ([SBU1ID]),
    CONSTRAINT [FK_UserRoleDataAccess_SubBusinessUnits2] FOREIGN KEY ([SBU2ID]) REFERENCES [MAS].[SubBusinessUnits2] ([SBU2ID]),
    CONSTRAINT [FK_UserRoleDataAccess_SubVerticals] FOREIGN KEY ([SubVerticalID]) REFERENCES [MAS].[SubVerticals] ([SubVerticalID]),
    CONSTRAINT [FK_UserRoleDataAccess_UserRoleMapping] FOREIGN KEY ([RoleMappingID]) REFERENCES [RLE].[UserRoleMapping] ([RoleMappingID]),
    CONSTRAINT [FK_UserRoleDataAccess_Verticals] FOREIGN KEY ([VerticalID]) REFERENCES [MAS].[Verticals] ([VerticalID])
) ON [PartitionShmeAssociateID] ([AssociateID]);


GO
CREATE CLUSTERED INDEX [ClusteredIndex_on_PartitionShmeAssociateID_637400044845167366]
    ON [RLE].[UserRoleDataAccess]([AssociateID] ASC)
    ON [PartitionShmeAssociateID] ([AssociateID]);


GO
CREATE NONCLUSTERED INDEX [IDX_UserRoleDataAccess_IsDeleted]
    ON [RLE].[UserRoleDataAccess]([IsDeleted] ASC)
    INCLUDE([RoleMappingID], [MarketID], [MarketUnitID], [BusinessUnitID], [SBU1ID], [SBU2ID], [VerticalID], [SubVerticalID], [ParentCustomerID], [CustomerID], [ProjectID], [PracticeID], [IndustrySegmentId])
    ON [PartitionShmeAssociateID] ([AssociateID]);

