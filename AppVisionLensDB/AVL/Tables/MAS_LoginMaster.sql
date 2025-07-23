CREATE TABLE [AVL].[MAS_LoginMaster] (
    [UserID]                  INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeID]              NVARCHAR (50)  NOT NULL,
    [ClientUserID]            NVARCHAR (50)  NULL,
    [EmployeeName]            NVARCHAR (100) NULL,
    [EmployeeEmail]           NVARCHAR (100) NULL,
    [ProjectID]               INT            NOT NULL,
    [CustomerID]              BIGINT         NULL,
    [HcmSupervisorID]         NVARCHAR (50)  NULL,
    [TSApproverID]            NVARCHAR (50)  NULL,
    [ManagerID]               NVARCHAR (50)  NULL,
    [Remarks]                 NVARCHAR (MAX) NULL,
    [EffectiveDate]           DATE           NULL,
    [TimeZoneId]              INT            NULL,
    [MandatoryHours]          DECIMAL (6, 2) NULL,
    [EffectiveEndDate]        DATETIME       NULL,
    [Billability_type]        NVARCHAR (50)  NULL,
    [LocationID]              INT            NULL,
    [IsDeleted]               BIT            NULL,
    [RoleID]                  INT            NULL,
    [IsAutoassignedTicket]    CHAR (1)       CONSTRAINT [DF__MAS_Login__IsAut__6D9742D9] DEFAULT ('Y') NULL,
    [ServiceLevelID]          INT            NULL,
    [CreatedDate]             DATETIME       NULL,
    [CreatedBy]               NVARCHAR (50)  NULL,
    [ModifiedDate]            DATETIME       NULL,
    [ModifiedBy]              NVARCHAR (50)  NULL,
    [TicketingModuleEnabled]  BIT            NULL,
    [IsDefaultProject]        BIT            NULL,
    [IsEffortTrackingEnabled] BIT            NULL,
    [Offshore_Onsite]         VARCHAR (3)    NULL,
    [IsNonESAAuthorized]      BIT            NULL,
    [IsMiniConfigured]        BIT            NULL,
    CONSTRAINT [PK_MAS_LoginMaster] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [uni_projectid_employeeid_LoginMaster] UNIQUE NONCLUSTERED ([EmployeeID] ASC, [ProjectID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_LoginMaster_CustomerID_Isdeleted]
    ON [AVL].[MAS_LoginMaster]([CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([HcmSupervisorID], [TSApproverID], [EmployeeID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_LoginMaster_ProjectID_Isdeleted]
    ON [AVL].[MAS_LoginMaster]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ClientUserID], [UserID]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180810-124139]
    ON [AVL].[MAS_LoginMaster]([EmployeeID] ASC, [ProjectID] ASC, [CustomerID] ASC, [IsDeleted] ASC, [UserID] ASC, [EmployeeName] ASC, [TimeZoneId] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180810-124215]
    ON [AVL].[MAS_LoginMaster]([UserID] ASC, [ProjectID] ASC, [CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([EmployeeID]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-UserID_Isdeleted]
    ON [AVL].[MAS_LoginMaster]([UserID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER24_MAS_LoginMaster_CustomerID_IsDeleted]
    ON [AVL].[MAS_LoginMaster]([CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectID], [HcmSupervisorID], [TSApproverID]);


GO
CREATE NONCLUSTERED INDEX [NIXJob16_MAS_LoginMaster_IsDeleted_TSApproverID]
    ON [AVL].[MAS_LoginMaster]([IsDeleted] ASC, [TSApproverID] ASC)
    INCLUDE([EmployeeID], [ProjectID]);


GO
CREATE NONCLUSTERED INDEX [NIXK2_MAS_LoginMaster_CustomerID_IsDeleted]
    ON [AVL].[MAS_LoginMaster]([CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([EmployeeID]);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID_HCM_TS]
    ON [AVL].[MAS_LoginMaster]([IsDeleted] ASC)
    INCLUDE([ProjectID], [HcmSupervisorID], [TSApproverID]);


GO
CREATE NONCLUSTERED INDEX [NCI_LoginMaster_CustomerID_IsDeletedwithinclude]
    ON [AVL].[MAS_LoginMaster]([CustomerID] ASC, [IsDeleted] ASC)
    INCLUDE([EmployeeID], [ProjectID], [HcmSupervisorID], [TSApproverID]);


GO
CREATE NONCLUSTERED INDEX [IX_LoginMaster_EmployeeID_CustomerID]
    ON [AVL].[MAS_LoginMaster]([EmployeeID] ASC, [CustomerID] ASC)
    INCLUDE([UserID], [EmployeeName], [ProjectID], [TimeZoneId]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_LoginMaster_CustomerID_IsDeleted_EmployeeID_IsNonESAAuthorized]
    ON [AVL].[MAS_LoginMaster]([CustomerID] ASC, [IsDeleted] ASC, [EmployeeID] ASC, [IsNonESAAuthorized] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_LoginMaster_ProjectID_CustomerID]
    ON [AVL].[MAS_LoginMaster]([ProjectID] ASC, [CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_LoginMaster_ProjectID_TSApproverID_HcmSupervisorID_CustomerID_IsDeleted]
    ON [AVL].[MAS_LoginMaster]([ProjectID] ASC, [TSApproverID] ASC, [HcmSupervisorID] ASC, [CustomerID] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_LoginMaster_UserID_ProjectID_TSApproverID_IsDeleted_CustomerID_EmployeeID]
    ON [AVL].[MAS_LoginMaster]([UserID] ASC, [ProjectID] ASC, [TSApproverID] ASC, [IsDeleted] ASC, [CustomerID] ASC, [EmployeeID] ASC)
    INCLUDE([EmployeeName]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_LoginMaster_UserID_ProjectID_TSApproverID_IsDeleted_CustomerID_EmployeeID_EmployeeName]
    ON [AVL].[MAS_LoginMaster]([UserID] ASC, [ProjectID] ASC, [TSApproverID] ASC, [IsDeleted] ASC, [CustomerID] ASC, [EmployeeID] ASC, [EmployeeName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_LoginMaster_ProjectID_CustomerID_EmployeeID_Isdeleted]
    ON [AVL].[MAS_LoginMaster]([ProjectID] ASC, [CustomerID] ASC, [EmployeeID] ASC, [IsDeleted] ASC);

