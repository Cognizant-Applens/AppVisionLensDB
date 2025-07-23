CREATE TABLE [dbo].[vw_CentralRepository_RHMS_Customer_Group] (
    [GlobalMarketId]         VARCHAR (10) NOT NULL,
    [GlobalMarketName]       VARCHAR (50) NOT NULL,
    [ActiveFlag]             INT          NOT NULL,
    [LastUpdatedDateTime]    DATETIME     NOT NULL,
    [RowLastUpdatedDateTime] DATETIME     NOT NULL,
    [RefreshDate]            DATETIME     DEFAULT (getdate()) NOT NULL,
    [RefreshBy]              VARCHAR (50) DEFAULT ('GetCentralRepository_RHMS_CustomerGroup') NOT NULL,
    PRIMARY KEY CLUSTERED ([GlobalMarketId] ASC)
);

