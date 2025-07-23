CREATE TABLE [AVL].[TK_MAS_ReleaseType] (
    [ReleaseTypeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ReleaseTypeName] NVARCHAR (50) NOT NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      CONSTRAINT [DF_TK_MAS_ReleaseType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    CONSTRAINT [PK_TK_MAS_ReleaseType] PRIMARY KEY CLUSTERED ([ReleaseTypeID] ASC)
);

