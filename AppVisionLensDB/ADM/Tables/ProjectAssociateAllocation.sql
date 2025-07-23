CREATE TABLE [ADM].[ProjectAssociateAllocation] (
    [Id]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [AssociateId]         NVARCHAR (50)   NULL,
    [EsaProjectId]        NVARCHAR (100)  NULL,
    [AllocationStartDate] DATETIME        NULL,
    [AllocationEndDate]   DATETIME        NULL,
    [AllocationPercent]   DECIMAL (10, 2) NULL,
    [BillabilityType]     VARCHAR (3)     NULL,
    [OffshoreOnsite]      CHAR (2)        NULL,
    [AssignmentStatus]    CHAR (1)        NULL,
    [AssignmentId]        CHAR (15)       NOT NULL,
    [ProjectRole]         VARCHAR (50)    NULL,
    [Location]            CHAR (10)       NULL,
    [ScheduleHr]          DECIMAL (10, 4) NULL,
    [IsDeleted]           BIT             NOT NULL,
    [CreatedBy]           NVARCHAR (50)   NOT NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [ModifiedBy]          NVARCHAR (50)   NULL,
    [ModifiedDate]        DATETIME        NULL
);

