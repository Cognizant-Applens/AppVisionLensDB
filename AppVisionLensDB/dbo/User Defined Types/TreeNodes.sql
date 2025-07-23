CREATE TYPE [dbo].[TreeNodes] AS TABLE (
    [ID]         NVARCHAR (50) NOT NULL,
    [Title]      NVARCHAR (50) NOT NULL,
    [Parent]     NVARCHAR (50) NULL,
    [Level]      NVARCHAR (50) NULL,
    [UserName]   NVARCHAR (50) NULL,
    [CustomerID] NVARCHAR (50) NULL);

