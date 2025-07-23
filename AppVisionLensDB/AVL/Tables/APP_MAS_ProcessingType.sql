CREATE TABLE [AVL].[APP_MAS_ProcessingType] (
    [ProcessingTypeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProcessingTypeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]          BIT           NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      CONSTRAINT [DF_APP_MAS_Processing_Type_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_Processing_Type] PRIMARY KEY CLUSTERED ([ProcessingTypeID] ASC)
);

