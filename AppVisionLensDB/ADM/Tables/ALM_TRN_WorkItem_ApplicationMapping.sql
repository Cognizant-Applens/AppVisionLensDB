CREATE TABLE [ADM].[ALM_TRN_WorkItem_ApplicationMapping] (
    [WorkItem_Application_MapId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [WorkItemDetailsId]          BIGINT        NOT NULL,
    [Application_Id]             BIGINT        NOT NULL,
    [IsDeleted]                  BIT           NOT NULL,
    [CreatedBy]                  NVARCHAR (50) NOT NULL,
    [CreatedDate]                DATETIME      NOT NULL,
    [ModifiedBy]                 NVARCHAR (50) NULL,
    [ModifiedDate]               DATETIME      NULL,
    CONSTRAINT [PK_ALM_TRN_WorkItem_ApplicationMapping] PRIMARY KEY CLUSTERED ([WorkItem_Application_MapId] ASC),
    CONSTRAINT [FK_ALM_TRN_WorkItem_ApplicationMapping_ALM_TRN_WorkItem_Details] FOREIGN KEY ([WorkItemDetailsId]) REFERENCES [ADM].[ALM_TRN_WorkItem_Details] ([WorkItemDetailsId]),
    CONSTRAINT [FK_ALM_TRN_WorkItem_ApplicationMapping_APP_MAS_ApplicationDetails] FOREIGN KEY ([Application_Id]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemApplicationMapping_WorkItemDetailsId]
    ON [ADM].[ALM_TRN_WorkItem_ApplicationMapping]([WorkItemDetailsId] ASC);

