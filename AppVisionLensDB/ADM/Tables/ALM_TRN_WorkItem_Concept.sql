CREATE TABLE [ADM].[ALM_TRN_WorkItem_Concept] (
    [ConceptId]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [WorkItemDetailsId]  BIGINT          NOT NULL,
    [IsConceptAvailable] BIT             NULL,
    [Description]        NVARCHAR (300)  NULL,
    [ArtifactFileName]   NVARCHAR (200)  NULL,
    [IsDeleted]          BIT             NOT NULL,
    [CreatedBy]          NVARCHAR (50)   NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [ModifiedBy]         NVARCHAR (50)   NULL,
    [ModifiedDate]       DATETIME        NULL,
    [Artifact_File]      VARBINARY (MAX) NULL,
    CONSTRAINT [PK_ALM_TRN_WorkItem_Concept] PRIMARY KEY CLUSTERED ([ConceptId] ASC),
    CONSTRAINT [FK_ALM_TRN_WorkItem_Details_WorkItemDetailsId] FOREIGN KEY ([WorkItemDetailsId]) REFERENCES [ADM].[ALM_TRN_WorkItem_Details] ([WorkItemDetailsId])
);

