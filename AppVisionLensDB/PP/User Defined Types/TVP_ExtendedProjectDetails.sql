CREATE TYPE [PP].[TVP_ExtendedProjectDetails] AS TABLE (
    [ProjectType]              INT            NULL,
    [OtherProjectType]         NVARCHAR (250) NULL,
    [ProjectShortDescription]  NVARCHAR (250) NULL,
    [ContractValue]            INT            NULL,
    [BusinessDriver]           INT            NULL,
    [OtherBusinessDriver]      NVARCHAR (250) NULL,
    [TechnicalDriver]          INT            NULL,
    [OtherTechnicalDriver]     NVARCHAR (250) NULL,
    [IsKEDBOwned]              BIT            NULL,
    [NoOfPODS]                 SMALLINT       NULL,
    [WorkItemSize]             SMALLINT       NULL,
    [VendorPresence]           BIT            NULL,
    [IsSubmitted]              BIT            NULL,
    [OtherWorkItemMeasurement] NVARCHAR (250) NULL,
    [OtherPricingModule]       NVARCHAR (250) NULL);

