CREATE TABLE [AVL].[InfraTowerHardwareAttributes] (
    [InfraTowerHardwareAttributeID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [InfraTowerTransactionID]       BIGINT        NOT NULL,
    [Type]                          NVARCHAR (50) NULL,
    [Item]                          NVARCHAR (50) NULL,
    [CopyOrSerialNumber]            NVARCHAR (50) NULL,
    [ModelNumberHardware]           NVARCHAR (50) NULL,
    [WarrantyExpiryDate]            DATETIME      NULL,
    [SourceSupplier]                NVARCHAR (50) NULL,
    [License]                       NVARCHAR (50) NULL,
    [SupplyDate]                    DATE          NULL,
    [AcceptedDate]                  DATE          NULL,
    [StatusScheduled]               NVARCHAR (50) NULL,
    [SLA]                           INT           NULL,
    [ServicePackAndPatchDetails]    NVARCHAR (50) NULL,
    [AdminGroups]                   NVARCHAR (50) NULL,
    [UserGroups]                    NVARCHAR (50) NULL,
    [IPAddress]                     NVARCHAR (50) NULL,
    [IsDeleted]                     BIT           NULL,
    [CreatedBy]                     NVARCHAR (50) NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ModifiedBy]                    NVARCHAR (50) NULL,
    [ModifiedDate]                  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraTowerHardwareAttributeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonInx_InfraTowerHardwareAttributes_InfraTowerTransactionID]
    ON [AVL].[InfraTowerHardwareAttributes]([InfraTowerTransactionID] ASC);

