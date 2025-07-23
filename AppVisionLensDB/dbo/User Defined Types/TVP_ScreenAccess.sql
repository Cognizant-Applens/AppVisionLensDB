CREATE TYPE [dbo].[TVP_ScreenAccess] AS TABLE (
    [RoleName] VARCHAR (100) NULL,
    [ScreenID] INT           NULL,
    [Read]     BIT           NULL,
    [Write]    BIT           NULL);

