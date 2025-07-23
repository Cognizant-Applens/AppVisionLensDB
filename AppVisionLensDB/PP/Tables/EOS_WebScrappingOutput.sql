CREATE TABLE [PP].[EOS_WebScrappingOutput] (
    [ProductId]   BIGINT         IDENTITY (100, 1) NOT NULL,
    [URLId]       INT            NOT NULL,
    [ProductName] NVARCHAR (255) NOT NULL,
    [Version]     NVARCHAR (255) NULL,
    [Build]       NVARCHAR (50)  NULL,
    [EOS]         NVARCHAR (255) NULL,
    [EOSExtended] NVARCHAR (255) NULL,
    [CreatedDate] DATETIME       NULL,
    [CreatedBy]   NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC)
);

