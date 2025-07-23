CREATE TABLE [PP].[Generic_MAP_WorkType] (
    [WorkTypeMapId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [WorkTypeId]          BIGINT         NOT NULL,
    [ProjectWorkTypeName] NVARCHAR (200) NOT NULL,
    [ProjectId]           BIGINT         NULL,
    [IsDefault]           CHAR (10)      NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    [IsEffortTracking]    BIT            NULL,
    CONSTRAINT [Generic_WorkType_WorkTypeMapId] PRIMARY KEY CLUSTERED ([WorkTypeMapId] ASC)
);

