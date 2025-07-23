CREATE TABLE [MAS].[ADM_Metric_UOM] (
    [UOMId]        INT            IDENTITY (1, 1) NOT NULL,
    [UOMDesc]      NVARCHAR (100) NOT NULL,
    [UOMDataType]  NVARCHAR (100) NOT NULL,
    [IsDeleted]    BIT            NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [CreatedDate]  DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_MAS.ADM_MS_UOM] PRIMARY KEY CLUSTERED ([UOMId] ASC)
);

