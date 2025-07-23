CREATE TABLE [PP].[ALM_MAS_ColumnName] (
    [ALMColID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ALMColumnName] NVARCHAR (200) NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [IsMandatory]   BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ALM_MAS_COLUMN_NAME_ALMColID] PRIMARY KEY CLUSTERED ([ALMColID] ASC)
);

