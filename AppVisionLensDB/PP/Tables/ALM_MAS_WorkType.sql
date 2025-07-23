CREATE TABLE [PP].[ALM_MAS_WorkType] (
    [WorkTypeId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [WorkTypeName]  NVARCHAR (200) NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [WorkTypeOrder] SMALLINT       NOT NULL,
    CONSTRAINT [PK_ALM_MAS_WorkType_WorkTypeId] PRIMARY KEY CLUSTERED ([WorkTypeId] ASC)
);

