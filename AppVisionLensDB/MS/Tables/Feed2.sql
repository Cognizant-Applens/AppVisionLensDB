CREATE TABLE [MS].[Feed2] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [UniqueID]              NVARCHAR (300) NULL,
    [ProjectID]             NVARCHAR (50)  NULL,
    [ProjectName]           NVARCHAR (100) NULL,
    [ServiceOfferingLevel2] NVARCHAR (100) NULL,
    [ServiceOfferingLevel3] NVARCHAR (100) NULL,
    [MetricName]            NVARCHAR (200) NULL,
    [M_SupportCategory]     NVARCHAR (50)  NULL,
    [M_Priority]            NVARCHAR (50)  NULL,
    [M_Technology]          NVARCHAR (10)  NULL,
    [Mandatory]             NVARCHAR (50)  NULL,
    [Applicability]         NVARCHAR (50)  NULL,
    [Numerator1]            NVARCHAR (100) NULL,
    [Numerator2]            NVARCHAR (100) NULL,
    [Numerator3]            NVARCHAR (100) NULL,
    [Denominator1]          NVARCHAR (100) NULL,
    [Denominator2]          NVARCHAR (100) NULL,
    [Denominator3]          NVARCHAR (100) NULL,
    CONSTRAINT [PK_Feed2] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

