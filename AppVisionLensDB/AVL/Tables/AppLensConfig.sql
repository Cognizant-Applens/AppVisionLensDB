CREATE TABLE [AVL].[AppLensConfig] (
    [ConfigId]     INT             IDENTITY (1, 1) NOT NULL,
    [ConfigValue]  NVARCHAR (4000) NOT NULL,
    [IsActive]     BIT             NOT NULL,
    [CreatedDate]  DATETIME        NULL,
    [ModifiedDate] DATETIME        NULL,
    [CreatedBy]    NVARCHAR (50)   NULL,
    [ModifiedBy]   NVARCHAR (50)   NULL,
    [ConfigName]   NVARCHAR (50)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ConfigId] ASC),
    UNIQUE NONCLUSTERED ([ConfigName] ASC)
);

