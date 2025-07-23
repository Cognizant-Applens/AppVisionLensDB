CREATE TABLE [AVL].[TK_MAS_ServiceActivityMapping] (
    [ServiceMappingID]  INT            IDENTITY (1, 1) NOT NULL,
    [ServiceTypeID]     NVARCHAR (50)  NULL,
    [ServiceID]         INT            NULL,
    [ServiceName]       NVARCHAR (50)  NULL,
    [ServiceShortName]  NVARCHAR (50)  NULL,
    [ActivityID]        INT            NULL,
    [ActivityName]      NVARCHAR (200) NULL,
    [EffortType]        NVARCHAR (50)  NULL,
    [MaintenanceType]   NVARCHAR (50)  NULL,
    [IsDeleted]         CHAR (1)       NULL,
    [CreatedDate]       DATETIME       NULL,
    [CreatedBy]         NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [COQ]               NVARCHAR (100) NULL,
    [Categorization]    NVARCHAR (100) NULL,
    [IsMasterData]      INT            NULL,
    [AutomatableTypeID] SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([ServiceMappingID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_MAS_ServiceActivityMapping_ServiceMappingID]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([ServiceMappingID] ASC)
    INCLUDE([ServiceTypeID], [ServiceID], [ActivityID], [ActivityName]);


GO
CREATE NONCLUSTERED INDEX [IX_TK_MAS_ServiceActivityMapping_AutID_SID_ServiceID_SName_IsDeleted]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([AutomatableTypeID] ASC)
    INCLUDE([ServiceMappingID], [ServiceID], [ServiceName], [ActivityName], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [NC_TK_MAS_ServiceActivityMapping_ActivityName]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([ActivityName] ASC);


GO
CREATE NONCLUSTERED INDEX [NIXK4_TK_MAS_ServiceActivityMapping_ServiceID]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([ServiceID] ASC)
    INCLUDE([ServiceMappingID], [ServiceTypeID]);


GO
CREATE NONCLUSTERED INDEX [NC_TK_MAS_ServiceActivityMapping_Service]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([ServiceTypeID] ASC, [ServiceID] ASC)
    INCLUDE([ActivityID], [ActivityName]);


GO
CREATE NONCLUSTERED INDEX [NC_TK_MAS_SerActMap_Service]
    ON [AVL].[TK_MAS_ServiceActivityMapping]([ServiceID] ASC)
    INCLUDE([ServiceMappingID], [ServiceName], [ServiceShortName], [IsDeleted]);

