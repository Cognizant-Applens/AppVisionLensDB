CREATE TABLE [PP].[ALM_MAP_Status] (
    [StatusMapId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [StatusId]          INT           NOT NULL,
    [ProjectStatusName] NVARCHAR (50) NOT NULL,
    [ProjectId]         BIGINT        NULL,
    [IsDefault]         CHAR (10)     NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    CONSTRAINT [PK_ALM_MAP_Status] PRIMARY KEY CLUSTERED ([StatusMapId] ASC),
    CONSTRAINT [FK_ALM_MAP_Status_ALM_MAS_Status] FOREIGN KEY ([StatusId]) REFERENCES [PP].[ALM_MAS_Status] ([StatusId]),
    CONSTRAINT [FK_ALM_MAP_Status_MAS_ProjectMaster] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_Status_IsDefault]
    ON [PP].[ALM_MAP_Status]([IsDefault] ASC)
    INCLUDE([StatusId], [ProjectStatusName]);


GO
CREATE NONCLUSTERED INDEX [NCI_Status_IsDeleted]
    ON [PP].[ALM_MAP_Status]([IsDeleted] ASC)
    INCLUDE([StatusId], [ProjectStatusName], [ProjectId]);


GO
CREATE NONCLUSTERED INDEX [NCI_Status_ProjectId_IsDeleted]
    ON [PP].[ALM_MAP_Status]([ProjectId] ASC, [IsDeleted] ASC)
    INCLUDE([StatusId], [ProjectStatusName]);

