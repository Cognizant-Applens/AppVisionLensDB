CREATE TABLE [AVL].[MAS_ServiceLevel] (
    [ServiceLevelID]   INT             NULL,
    [ServiceLevelName] NVARCHAR (1000) NULL,
    [IsDeleted]        BIT             NULL,
    [CreatedBy]        NVARCHAR (50)   NULL,
    [CreatedDate]      DATETIME        NULL,
    [ModifiedBy]       NVARCHAR (50)   NULL,
    [ModifiedDate]     DATETIME        NULL
);

