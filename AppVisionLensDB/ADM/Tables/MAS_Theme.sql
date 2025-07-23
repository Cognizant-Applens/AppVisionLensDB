CREATE TABLE [ADM].[MAS_Theme] (
    [ThemeId]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ThemeName]    NVARCHAR (200) NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_ALM_MAS_Priority_PriorityId] PRIMARY KEY CLUSTERED ([ThemeId] ASC)
);

