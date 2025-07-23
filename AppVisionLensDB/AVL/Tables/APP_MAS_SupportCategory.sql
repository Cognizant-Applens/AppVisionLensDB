CREATE TABLE [AVL].[APP_MAS_SupportCategory] (
    [SupportCategoryID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SupportCategoryName] NVARCHAR (50) NOT NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      CONSTRAINT [DF_APP_Support_Category_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    CONSTRAINT [PK_APP_Support_Category] PRIMARY KEY CLUSTERED ([SupportCategoryID] ASC)
);

