CREATE TYPE [dbo].[TVP_ScreenAccess_RHMS] AS TABLE (
    [RoleID]   INT NULL,
    [ScreenID] INT NULL,
    [Read]     BIT NULL,
    [Write]    BIT NULL);

