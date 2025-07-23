CREATE TABLE [ESA].[AccountHierarchyDetails] (
    [Peoplesoft_Customer_Id] VARCHAR (15)  NOT NULL,
    [Customer_Name]          VARCHAR (80)  NOT NULL,
    [Market_Id]              VARCHAR (255) NULL,
    [Market]                 VARCHAR (255) NOT NULL,
    [Global_Market_Id]       VARCHAR (255) NULL,
    [Global_Market]          VARCHAR (100) NOT NULL,
    [BU_Id]                  VARCHAR (255) NULL,
    [Bu]                     VARCHAR (100) NOT NULL,
    [VerticalID]             VARCHAR (255) NULL,
    [Vertical]               VARCHAR (100) NOT NULL
);

