CREATE TABLE [MAS].[ApplensModules] (
    [ModuleId]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ModuleName]   NVARCHAR (200) NOT NULL,
    [HubId]        BIGINT         NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreaetedDate] DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ModuleId] ASC),
    FOREIGN KEY ([HubId]) REFERENCES [MAS].[Hub] ([HubId])
);

