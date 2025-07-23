CREATE TABLE [ADM].[ALM_TRN_WorkItem_Details] (
    [WorkItemDetailsId]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [WorkTypeMapId]        BIGINT          NOT NULL,
    [Project_Id]           BIGINT          NOT NULL,
    [WorkItem_Id]          NVARCHAR (100)  NOT NULL,
    [WorkItem_Title]       NVARCHAR (MAX)  NOT NULL,
    [WorkItem_Description] NVARCHAR (MAX)  NULL,
    [StatusMapId]          BIGINT          NOT NULL,
    [Tool_Activity]        NVARCHAR (250)  NULL,
    [Assignee]             NVARCHAR (50)   NULL,
    [ServiceId]            INT             NULL,
    [PriorityMapId]        BIGINT          NULL,
    [SeverityMapId]        BIGINT          NULL,
    [Risk]                 NVARCHAR (250)  NULL,
    [Order]                INT             NULL,
    [Actual_StartDate]     DATETIME        NULL,
    [Actual_EndDate]       DATETIME        NULL,
    [Planned_StartDate]    DATETIME        NULL,
    [Planned_EndDate]      DATETIME        NULL,
    [Estimation_Points]    NVARCHAR (100)  NULL,
    [Planned_Estimate]     DECIMAL (18, 2) NULL,
    [Actual_Effort]        DECIMAL (18, 2) NULL,
    [SprintDetailsId]      BIGINT          NULL,
    [Target_Date]          DATETIME        NULL,
    [Assignment_Group]     BIGINT          NULL,
    [ADMSourceId]          BIGINT          NOT NULL,
    [ThemeMapId]           BIGINT          NULL,
    [Linked_ParentID]      NVARCHAR (100)  NULL,
    [Linked_ChildID]       BIGINT          NULL,
    [IsDeleted]            BIT             NOT NULL,
    [CreatedBy]            NVARCHAR (50)   NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [ModifiedBy]           NVARCHAR (50)   NULL,
    [ModifiedDate]         DATETIME        NULL,
    [Activity]             NVARCHAR (250)  NULL,
    [OtherALM_ToolOrder]   INT             NULL,
    [IsMilestonemet]       BIT             NULL,
    [WorkProfilerEffort]   DECIMAL (18, 2) NULL,
    [BugPhaseTypeMapId]    SMALLINT        NULL,
    CONSTRAINT [PK_ALM_TRN_WorkItem_Details] PRIMARY KEY CLUSTERED ([WorkItemDetailsId] ASC),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_ALM_MAP_Priority] FOREIGN KEY ([SprintDetailsId]) REFERENCES [ADM].[ALM_TRN_Sprint_Details] ([SprintDetailsId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_ALM_MAP_Priority1] FOREIGN KEY ([PriorityMapId]) REFERENCES [PP].[ALM_MAP_Priority] ([PriorityMapId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_ALM_MAP_Severity] FOREIGN KEY ([SeverityMapId]) REFERENCES [PP].[ALM_MAP_Severity] ([SeverityMapId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_ALM_MAP_Status] FOREIGN KEY ([StatusMapId]) REFERENCES [PP].[ALM_MAP_Status] ([StatusMapId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_ALM_MAP_WorkType] FOREIGN KEY ([WorkTypeMapId]) REFERENCES [PP].[ALM_MAP_WorkType] ([WorkTypeMapId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_MAP_Theme] FOREIGN KEY ([ThemeMapId]) REFERENCES [ADM].[MAP_Theme] ([ThemeMapId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_MAS_ProjectMaster] FOREIGN KEY ([Project_Id]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_MAS_Source] FOREIGN KEY ([ADMSourceId]) REFERENCES [ADM].[MAS_Source] ([SourceId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_TK_MAS_Service] FOREIGN KEY ([ServiceId]) REFERENCES [AVL].[TK_MAS_Service] ([ServiceID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemDetails_ProjectId]
    ON [ADM].[ALM_TRN_WorkItem_Details]([Project_Id] ASC)
    INCLUDE([WorkTypeMapId], [WorkItem_Id], [Linked_ParentID]);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemDetails_ProjectId_IsDeleted]
    ON [ADM].[ALM_TRN_WorkItem_Details]([Project_Id] ASC, [IsDeleted] ASC)
    INCLUDE([WorkItem_Id]);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemDetails_ProjectId_WorkItemId_IsDeleted]
    ON [ADM].[ALM_TRN_WorkItem_Details]([Project_Id] ASC, [WorkItem_Id] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemDetails_WorkItemId]
    ON [ADM].[ALM_TRN_WorkItem_Details]([WorkItem_Id] ASC)
    INCLUDE([Linked_ParentID]);


GO
CREATE NONCLUSTERED INDEX [IX_ADM.ALM_TRN_WorkItem_Details_WorkItemDetailsId_Project_Id]
    ON [ADM].[ALM_TRN_WorkItem_Details]([WorkItemDetailsId] ASC, [Project_Id] ASC);

