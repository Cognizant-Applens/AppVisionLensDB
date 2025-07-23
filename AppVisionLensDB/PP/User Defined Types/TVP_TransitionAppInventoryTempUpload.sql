CREATE TYPE [PP].[TVP_TransitionAppInventoryTempUpload] AS TABLE (
    [ApplicationName]              NVARCHAR (100) NULL,
    [KTNeeded]                     VARCHAR (50)   NOT NULL,
    [LanguageRequirements]         VARCHAR (50)   NOT NULL,
    [WaveOrCluster]                NVARCHAR (100) NULL,
    [ApplicationOwnerIT]           NVARCHAR (50)  NULL,
    [CRType]                       NVARCHAR (50)  NOT NULL,
    [HardwareSoftwareRequirements] NVARCHAR (100) NULL,
    [BusinessFunction]             NVARCHAR (50)  NULL,
    [OperationallyCritical]        CHAR (10)      NULL,
    [SecurityCritical]             CHAR (10)      NULL,
    [HighTouch]                    CHAR (50)      NULL,
    [PricePerMonth]                VARCHAR (50)   NULL,
    [SLALevel]                     NVARCHAR (50)  NULL,
    [VendorTypeName]               NVARCHAR (50)  NOT NULL,
    [VendorName]                   NVARCHAR (50)  NULL,
    [OtherVendorTypeName]          NVARCHAR (50)  NULL);

