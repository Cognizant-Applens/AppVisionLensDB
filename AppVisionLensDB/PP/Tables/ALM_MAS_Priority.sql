CREATE TABLE [PP].[ALM_MAS_Priority] (
    [PriorityId]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [PriorityName] NVARCHAR (100) NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_ALM_MAS_Priority_PriorityId] PRIMARY KEY CLUSTERED ([PriorityId] ASC)
);

