CREATE TABLE [AVL].[TK_MAS_ServiceMapping] (
    [ServiceMappingID] INT            IDENTITY (1, 1) NOT NULL,
    [ServiceTypeID]    NVARCHAR (50)  NULL,
    [ServiceID]        INT            NULL,
    [ServiceName]      NVARCHAR (50)  NULL,
    [ServiceShortName] NVARCHAR (50)  NULL,
    [CategoryID]       INT            NULL,
    [CategoryName]     NVARCHAR (50)  NULL,
    [ActivityID]       INT            NULL,
    [ActivityName]     NVARCHAR (200) NULL,
    [EffortType]       NVARCHAR (50)  NULL,
    [MaintenanceType]  NVARCHAR (50)  NULL,
    [IsDeleted]        CHAR (1)       NULL,
    [CreatedDate]      DATETIME       NULL,
    [CreatedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [COQ]              NVARCHAR (100) NULL,
    [Categorization]   NVARCHAR (100) NULL,
    CONSTRAINT [PK_ServiceMapping] PRIMARY KEY CLUSTERED ([ServiceMappingID] ASC) WITH (FILLFACTOR = 70)
);

