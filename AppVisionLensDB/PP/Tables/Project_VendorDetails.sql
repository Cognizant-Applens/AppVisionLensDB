CREATE TABLE [PP].[Project_VendorDetails] (
    [VendorDetailID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]      BIGINT         NOT NULL,
    [VendorName]     NVARCHAR (250) NOT NULL,
    [VendorScopeID]  INT            NULL,
    [IsDeleted]      BIT            NOT NULL,
    [CreatedBy]      NVARCHAR (50)  NOT NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([VendorDetailID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

