CREATE TABLE [AVL].[InfraTowerPhysicalResourceAttributes] (
    [InfraTowerPhysicalResourceAttributeID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [InfraTowerTransactionID]               BIGINT        NOT NULL,
    [Location]                              NVARCHAR (50) NULL,
    [NatureOfEmployment]                    NVARCHAR (50) NULL,
    [IsDeleted]                             BIT           NULL,
    [CreatedBy]                             NVARCHAR (50) NULL,
    [CreatedDate]                           DATETIME      NULL,
    [ModifiedBy]                            NVARCHAR (50) NULL,
    [ModifiedDate]                          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraTowerPhysicalResourceAttributeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonInx_InfraTowerPhysicalResourceAttributes_InfraTowerTransactionID]
    ON [AVL].[InfraTowerPhysicalResourceAttributes]([InfraTowerTransactionID] ASC);

