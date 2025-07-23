CREATE TABLE [ADM].[ALM_RetrospectionActions] (
    [RetrospectionActionId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [RetrospectionPointId]  BIGINT         NOT NULL,
    [Descriptions]          NVARCHAR (500) NULL,
    [AssignedTo]            NVARCHAR (50)  NOT NULL,
    [createdBy]             NVARCHAR (50)  NOT NULL,
    [Createdon]             DATETIME       NOT NULL,
    [isdeleted]             BIT            NOT NULL,
    [modifiedby]            NVARCHAR (50)  NULL,
    [modifiedon]            DATETIME       NULL,
    CONSTRAINT [PK_ALM_RetrospectionActionId] PRIMARY KEY CLUSTERED ([RetrospectionActionId] ASC),
    FOREIGN KEY ([RetrospectionPointId]) REFERENCES [ADM].[TRN_RetrospectionPoints] ([RetrospectionPointId])
);

