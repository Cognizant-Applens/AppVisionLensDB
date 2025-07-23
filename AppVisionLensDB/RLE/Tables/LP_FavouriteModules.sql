CREATE TABLE [RLE].[LP_FavouriteModules] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [ModuleId]     BIGINT        NULL,
    [Employeeid]   NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([ModuleId]) REFERENCES [MAS].[ApplensModules] ([ModuleId]),
    FOREIGN KEY ([ModuleId]) REFERENCES [MAS].[ApplensModules] ([ModuleId])
);

