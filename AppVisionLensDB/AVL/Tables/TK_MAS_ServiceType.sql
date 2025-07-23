CREATE TABLE [AVL].[TK_MAS_ServiceType] (
    [ServiceTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [ServiceTypeName] NVARCHAR (50) NOT NULL,
    [Isdeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      CONSTRAINT [DF_TK_MAS_ServiceType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ServiceTypeID] ASC)
);

