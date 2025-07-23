CREATE TABLE [MS].[MAS_TechnologyLanguage_Master] (
    [MainspringTechnologyLanguageID]   INT            IDENTITY (1, 1) NOT NULL,
    [MainspringTechnologyName]         NVARCHAR (200) NULL,
    [MainspringTechnologyLanguageName] NCHAR (10)     NULL,
    [TechnologyLanguageNameShortDESC]  NVARCHAR (50)  NULL,
    [IsDeleted]                        BIT            NULL,
    CONSTRAINT [PK_TechnologyLanguage_Master] PRIMARY KEY CLUSTERED ([MainspringTechnologyLanguageID] ASC) WITH (FILLFACTOR = 70)
);

