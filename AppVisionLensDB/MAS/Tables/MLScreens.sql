CREATE TABLE [MAS].[MLScreens] (
    [ScreenId]     SMALLINT      IDENTITY (1, 1) NOT NULL,
    [ScreenName]   NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    [RouterLink]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_MLScreens] PRIMARY KEY CLUSTERED ([ScreenId] ASC)
);

