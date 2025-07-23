CREATE TABLE [MAS].[MainspringArchetypeActivityMapping] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [ActivityId]   BIGINT        NOT NULL,
    [ArchetypeId]  BIGINT        NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

