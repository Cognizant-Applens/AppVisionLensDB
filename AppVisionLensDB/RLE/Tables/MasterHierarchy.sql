CREATE TABLE [RLE].[MasterHierarchy] (
    [MarketID]            INT            NOT NULL,
    [MarketName]          NVARCHAR (100) NOT NULL,
    [MarketUnitID]        INT            NOT NULL,
    [MarketUnitName]      NVARCHAR (100) NOT NULL,
    [BusinessUnitID]      INT            NOT NULL,
    [BusinessUnitName]    NVARCHAR (100) NOT NULL,
    [SBU1ID]              INT            NULL,
    [SBU1Name]            NVARCHAR (200) NULL,
    [SBU2ID]              INT            NULL,
    [SBU2Name]            NVARCHAR (100) NULL,
    [VerticalID]          INT            NOT NULL,
    [VerticalName]        NVARCHAR (100) NOT NULL,
    [SubVerticalID]       INT            NULL,
    [SubVerticalName]     NVARCHAR (100) NULL,
    [ParentCustomerID]    INT            NULL,
    [ParentCustomerName]  NVARCHAR (160) NULL,
    [CustomerID]          INT            NOT NULL,
    [CustomerName]        NVARCHAR (160) NOT NULL,
    [ESACustomerID]       NVARCHAR (50)  NOT NULL,
    [PracticeID]          INT            NULL,
    [PracticeName]        NVARCHAR (100) NULL,
    [ProjectID]           INT            NULL,
    [ProjectName]         NVARCHAR (500) NULL,
    [ESAProjectID]        NVARCHAR (30)  NULL,
    [IndustrySegmentId]   INT            NULL,
    [IndustrySegmentName] NVARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy]
    ON [RLE].[MasterHierarchy]([ProjectID] ASC, [PracticeID] ASC, [CustomerID] ASC, [BusinessUnitID] ASC, [MarketID] ASC, [MarketUnitID] ASC, [SBU1ID] ASC, [SBU2ID] ASC, [VerticalID] ASC, [SubVerticalID] ASC, [ParentCustomerID] ASC)
    INCLUDE([MarketName], [MarketUnitName], [BusinessUnitName], [SBU1Name], [SBU2Name], [VerticalName], [SubVerticalName], [ParentCustomerName], [CustomerName], [ESACustomerID], [PracticeName], [ProjectName], [ESAProjectID]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_BusinessUnitID]
    ON [RLE].[MasterHierarchy]([BusinessUnitID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_CustomerId]
    ON [RLE].[MasterHierarchy]([CustomerID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_IndustrySegmentID]
    ON [RLE].[MasterHierarchy]([IndustrySegmentId] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_MarketID]
    ON [RLE].[MasterHierarchy]([MarketID] ASC)
    INCLUDE([MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_MarketUnitID]
    ON [RLE].[MasterHierarchy]([MarketUnitID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_ParentCustomerID]
    ON [RLE].[MasterHierarchy]([ParentCustomerID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_PracticeID]
    ON [RLE].[MasterHierarchy]([PracticeID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_ProjectID]
    ON [RLE].[MasterHierarchy]([ProjectID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_SBU1ID]
    ON [RLE].[MasterHierarchy]([SBU1ID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_SBU2ID]
    ON [RLE].[MasterHierarchy]([SBU2ID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_SubVerticalID]
    ON [RLE].[MasterHierarchy]([SubVerticalID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalID], [VerticalName], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);


GO
CREATE NONCLUSTERED INDEX [IDX_MasterHierarchy_VerticalID]
    ON [RLE].[MasterHierarchy]([VerticalID] ASC)
    INCLUDE([MarketID], [MarketName], [MarketUnitID], [MarketUnitName], [BusinessUnitID], [BusinessUnitName], [SBU1ID], [SBU1Name], [SBU2ID], [SBU2Name], [VerticalName], [SubVerticalID], [SubVerticalName], [ParentCustomerID], [ParentCustomerName], [CustomerID], [CustomerName], [ESACustomerID], [PracticeID], [PracticeName], [ProjectID], [ProjectName], [ESAProjectID], [IndustrySegmentId], [IndustrySegmentName]);

