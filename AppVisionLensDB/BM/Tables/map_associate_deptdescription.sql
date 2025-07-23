CREATE TABLE [BM].[map_associate_deptdescription] (
    [AssociateID]           INT           NOT NULL,
    [DepartmentDescription] NVARCHAR (50) NULL,
    [Month]                 INT           NOT NULL,
    [Year]                  INT           NOT NULL,
    [CreatedBy]             NVARCHAR (50) NOT NULL,
    [CreatedDate]           DATETIME2 (7) NOT NULL,
    [IsDeleted]             INT           NOT NULL,
    [ModifiedBy]            NVARCHAR (1)  NULL,
    [ModifiedDate]          NVARCHAR (1)  NULL
);

