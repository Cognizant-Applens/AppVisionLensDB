CREATE TABLE [MAS].[MAS_LanguageMaster] (
    [LanguageID]      INT            IDENTITY (1, 1) NOT NULL,
    [LanguageName]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [CreatedBy]       NVARCHAR (50)  NOT NULL,
    [ModifiedDate]    DATETIME       NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    [IsDeleted]       BIT            NOT NULL,
    [LanguageValue]   VARCHAR (255)  NOT NULL,
    [ContentIsActive] BIT            NULL,
    [Language]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MAS_LanguageMaster] PRIMARY KEY CLUSTERED ([LanguageID] ASC)
);

