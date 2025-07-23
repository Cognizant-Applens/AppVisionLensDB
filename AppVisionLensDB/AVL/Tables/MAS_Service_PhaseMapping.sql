CREATE TABLE [AVL].[MAS_Service_PhaseMapping] (
    [ServicePhaseMapId] INT           IDENTITY (1, 1) NOT NULL,
    [ServiceMappingId]  INT           NOT NULL,
    [PhaseId]           INT           NOT NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedOn]         DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedOn]        DATETIME      NULL,
    CONSTRAINT [PK_MAS_Service_PhaseMapping] PRIMARY KEY CLUSTERED ([ServicePhaseMapId] ASC),
    FOREIGN KEY ([PhaseId]) REFERENCES [AVL].[MAS_Phase] ([PhaseId]),
    FOREIGN KEY ([ServiceMappingId]) REFERENCES [AVL].[TK_MAS_ServiceActivityMapping] ([ServiceMappingID])
);

