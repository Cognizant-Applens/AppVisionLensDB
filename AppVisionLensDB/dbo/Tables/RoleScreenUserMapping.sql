CREATE TABLE [dbo].[RoleScreenUserMapping] (
    [ID]         INT IDENTITY (1, 1) NOT NULL,
    [UserID]     INT NULL,
    [CustomerID] INT NULL,
    [RoleID]     INT NULL,
    [ScreenID]   INT NULL,
    [Read]       BIT NULL,
    [Write]      BIT NULL,
    CONSTRAINT [PK_RoleScreenUserMapping] PRIMARY KEY CLUSTERED ([ID] ASC)
);

