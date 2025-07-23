CREATE TABLE [MAS].[ADM_MetricMaster] (
    [MetricMasterId]   INT            IDENTITY (1, 1) NOT NULL,
    [MetricMasterName] NVARCHAR (200) NOT NULL,
    [Type]             VARCHAR (50)   NOT NULL,
    [IsDeleted]        BIT            NULL,
    [CreatedBy]        NVARCHAR (50)  NULL,
    [CreatedDate]      DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    CONSTRAINT [PK_MAS.ADM_MS_MetricMaster] PRIMARY KEY CLUSTERED ([MetricMasterId] ASC)
);

