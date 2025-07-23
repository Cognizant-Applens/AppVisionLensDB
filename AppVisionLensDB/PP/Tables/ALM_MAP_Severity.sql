CREATE TABLE [PP].[ALM_MAP_Severity] (
    [SeverityMapId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [SeverityId]          INT           NOT NULL,
    [ProjectSeverityName] NVARCHAR (50) NOT NULL,
    [ProjectId]           BIGINT        NULL,
    [IsDefault]           CHAR (10)     NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    CONSTRAINT [PK_ALM_MAP_Severity] PRIMARY KEY CLUSTERED ([SeverityMapId] ASC),
    CONSTRAINT [FK_ALM_MAP_Severity_ALM_MAS_Severity] FOREIGN KEY ([SeverityId]) REFERENCES [PP].[ALM_MAS_Severity] ([SeverityId]),
    CONSTRAINT [FK_ALM_MAP_Severity_MAS_ProjectMaster] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

