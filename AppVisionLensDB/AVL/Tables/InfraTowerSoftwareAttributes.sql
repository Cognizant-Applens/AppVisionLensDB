CREATE TABLE [AVL].[InfraTowerSoftwareAttributes] (
    [InfraTowerSoftwareAttributeID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [InfraTowerTransactionID]       BIGINT        NOT NULL,
    [Name]                          NVARCHAR (50) NULL,
    [ProductName]                   NVARCHAR (50) NULL,
    [Function]                      NVARCHAR (50) NULL,
    [Owner]                         NVARCHAR (50) NULL,
    [Version]                       NVARCHAR (50) NULL,
    [Contact]                       NVARCHAR (50) NULL,
    [Category]                      NVARCHAR (50) NULL,
    [ProductionDate]                DATE          NULL,
    [Hotfix]                        NVARCHAR (50) NULL,
    [ServicePack]                   NVARCHAR (50) NULL,
    [Supplier]                      NVARCHAR (50) NULL,
    [Status]                        NVARCHAR (50) NULL,
    [IsDeleted]                     BIT           NULL,
    [CreatedBy]                     NVARCHAR (50) NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ModifiedBy]                    NVARCHAR (50) NULL,
    [ModifiedDate]                  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraTowerSoftwareAttributeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonInx_InfraTowerSoftwareAttributes_InfraTowerTransactionID]
    ON [AVL].[InfraTowerSoftwareAttributes]([InfraTowerTransactionID] ASC);

