CREATE TYPE [AVL].[TipsModel] AS TABLE (
    [TipID]         INT            NOT NULL,
    [TipName]       VARCHAR (250)  NULL,
    [TipContent]    VARCHAR (4000) NULL,
    [ModuleID]      INT            NULL,
    [SubModuleID]   INT            NULL,
    [ExpiryDate]    DATETIME       NULL,
    [isActive]      BIT            NULL,
    [CreatedDate]   DATETIME       NULL,
    [ModifiedDate]  DATETIME       NULL,
    [CreatedBy]     VARCHAR (50)   NULL,
    [ModifiedBy]    VARCHAR (50)   NULL,
    [FeatureType]   VARCHAR (25)   NULL,
    [ModuleName]    VARCHAR (50)   NULL,
    [SubModuleName] VARCHAR (50)   NULL);

