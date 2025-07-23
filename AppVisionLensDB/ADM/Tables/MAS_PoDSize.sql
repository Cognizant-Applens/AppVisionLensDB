CREATE TABLE [ADM].[MAS_PoDSize] (
    [PoD_SizeID]   TINYINT       IDENTITY (1, 1) NOT NULL,
    [PoD_Size]     NVARCHAR (20) NOT NULL,
    [Min]          TINYINT       NOT NULL,
    [Max]          TINYINT       NOT NULL,
    [IsDeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50) DEFAULT ('System') NOT NULL,
    [CreatedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_PoD_SizeID] PRIMARY KEY CLUSTERED ([PoD_SizeID] ASC)
);

