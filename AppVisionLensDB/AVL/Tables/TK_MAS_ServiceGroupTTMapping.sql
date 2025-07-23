CREATE TABLE [AVL].[TK_MAS_ServiceGroupTTMapping] (
    [ServiceTTMappingID] INT           IDENTITY (1, 1) NOT NULL,
    [ServiceTypeID]      NVARCHAR (50) NULL,
    [ServiceID]          INT           NULL,
    [ServiceLevelID]     INT           NULL,
    [ServiceTicketType]  NVARCHAR (50) NULL,
    [IsDeleted]          CHAR (1)      NULL,
    [CreatedDate]        DATETIME      NULL,
    [CreatedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    [ModifiedBy]         NVARCHAR (50) NULL
);

