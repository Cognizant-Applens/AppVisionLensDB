CREATE TABLE [AVL].[APP_MAS_PrimaryTechnology] (
    [PrimaryTechnologyID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [PrimaryTechnologyName] NVARCHAR (50) NOT NULL,
    [IsDeleted]             BIT           NOT NULL,
    [CreatedBy]             NVARCHAR (50) NOT NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_APP_MAS_PrimaryTechnology_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [ModifiedDate]          DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_PrimaryTechnology] PRIMARY KEY CLUSTERED ([PrimaryTechnologyID] ASC)
);

