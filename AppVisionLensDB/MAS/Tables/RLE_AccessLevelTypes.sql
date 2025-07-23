CREATE TABLE [MAS].[RLE_AccessLevelTypes] (
    [AccessLevelTypeID]   INT            IDENTITY (1, 1) NOT NULL,
    [AccessLevelTypeName] NVARCHAR (100) NOT NULL,
    [IsDeleted]           BIT            CONSTRAINT [DF_RLE_AccessLevelTypes_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    CONSTRAINT [PK_RLE_AccessLevelTypes] PRIMARY KEY CLUSTERED ([AccessLevelTypeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_RLE_AccessLevelTypes]
    ON [MAS].[RLE_AccessLevelTypes]([AccessLevelTypeName] ASC, [IsDeleted] ASC);

