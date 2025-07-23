CREATE TABLE [MAS].[RLE_Groups] (
    [GroupID]      INT           IDENTITY (1, 1) NOT NULL,
    [GroupName]    NCHAR (100)   NOT NULL,
    [IsDeleted]    BIT           CONSTRAINT [DF_RLE_Groups_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_RLE_Groups] PRIMARY KEY CLUSTERED ([GroupID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_RLE_Groups]
    ON [MAS].[RLE_Groups]([GroupName] ASC, [IsDeleted] ASC);

