CREATE TABLE [PP].[ALM_MAP_Priority] (
    [PriorityMapId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [PriorityId]          BIGINT         NOT NULL,
    [ProjectPriorityName] NVARCHAR (100) NOT NULL,
    [ProjectId]           BIGINT         NULL,
    [IsDefault]           CHAR (10)      NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    CONSTRAINT [PK_ALM_MAP_Priority_PriorityMapId] PRIMARY KEY CLUSTERED ([PriorityMapId] ASC),
    CONSTRAINT [FK_ALM_MAP_Priority_PriorityId] FOREIGN KEY ([PriorityId]) REFERENCES [PP].[ALM_MAS_Priority] ([PriorityId]),
    CONSTRAINT [FK_ALM_MAP_Priority_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

