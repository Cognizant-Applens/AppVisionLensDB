CREATE TABLE [AVL].[AppLensConfiguration] (
    [ConfigurationId]    INT             NOT NULL,
    [ConfigurationValue] NVARCHAR (4000) NOT NULL,
    [IsActive]           BIT             NOT NULL,
    [CreatedDate]        DATETIME        NULL,
    [ModifiedDate]       DATETIME        NULL,
    [CreatedBy]          NVARCHAR (50)   NULL,
    [ModifiedBy]         NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([ConfigurationId] ASC)
);

