CREATE TABLE [AVL].[CustomerProjectMapping] (
    [CustomerProjectMapID] INT            IDENTITY (1, 1) NOT NULL,
    [OnpremAccountID]      NVARCHAR (50)  NOT NULL,
    [OnPremProjectID]      BIGINT         NOT NULL,
    [OnPremProjectName]    NVARCHAR (50)  NOT NULL,
    [EsaProjectID]         NVARCHAR (50)  NOT NULL,
    [ProjectID]            BIGINT         NULL,
    [CustomerID]           NVARCHAR (50)  NOT NULL,
    [IsDeleted]            BIT            NULL,
    [CreatedBy]            NVARCHAR (100) NULL,
    [CreatedDate]          DATETIME       NULL,
    [ModifiedBy]           NVARCHAR (100) NULL,
    [ModifiedDate]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([CustomerProjectMapID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

