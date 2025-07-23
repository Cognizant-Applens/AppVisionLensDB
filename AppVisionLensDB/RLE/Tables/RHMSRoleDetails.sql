CREATE TABLE [RLE].[RHMSRoleDetails] (
    [RoleId]                  NVARCHAR (40)  NOT NULL,
    [AssociateID]             NVARCHAR (50)  NOT NULL,
    [PrimaryPortfolioName]    VARCHAR (100)  NULL,
    [PrimaryPortfolioType]    NVARCHAR (100) NULL,
    [PrimaryPortfolioId]      NVARCHAR (10)  NOT NULL,
    [PortfolioQualifier1Id]   NVARCHAR (200) NOT NULL,
    [ActiveFlag]              CHAR (1)       NULL,
    [LastUpdatedDateTime]     DATETIME       NOT NULL,
    [PortfolioQualifier1Type] NVARCHAR (50)  NULL,
    [PortfolioQualifier2Id]   NVARCHAR (200) NOT NULL,
    [PortfolioQualifier2Type] NVARCHAR (50)  NULL
);

