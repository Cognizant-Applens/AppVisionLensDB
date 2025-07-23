CREATE TABLE [PP].[ALM_MAS_SprintStatus] (
    [SprintStatusId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SprintStatusName] NVARCHAR (50) NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDate]     DATETIME      NULL,
    CONSTRAINT [PK_ALM_MAS_SprintStatus] PRIMARY KEY CLUSTERED ([SprintStatusId] ASC)
);

