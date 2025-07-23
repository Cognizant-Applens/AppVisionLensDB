CREATE TABLE [dbo].[LogOnBannerDetails] (
    [Id]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ModuleName]   NVARCHAR (250) NOT NULL,
    [AssociateId]  NVARCHAR (50)  NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_LogOnBannerDetails_IsDeleted] DEFAULT ((0)) NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_LogOnBannerDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_LogOnBannerDetails]
    ON [dbo].[LogOnBannerDetails]([ModuleName] ASC, [AssociateId] ASC, [IsDeleted] ASC);

