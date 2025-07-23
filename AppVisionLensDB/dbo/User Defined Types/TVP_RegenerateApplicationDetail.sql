CREATE TYPE [dbo].[TVP_RegenerateApplicationDetail] AS TABLE (
    [ApplicationID]   INT            NOT NULL,
    [ApplicationName] NVARCHAR (MAX) NULL,
    [PortfolioID]     INT            NOT NULL,
    [PortfolioName]   NVARCHAR (MAX) NULL,
    [AppGroupID]      INT            NOT NULL,
    [AppGroupName]    NVARCHAR (MAX) NULL);

