CREATE TABLE [AVL].[BUServiceIDBenchMarkMapping] (
    [BUSBMMapID]   INT            IDENTITY (1, 1) NOT NULL,
    [BUID]         INT            NOT NULL,
    [ServiceID]    INT            NOT NULL,
    [BenchMark]    FLOAT (53)     NOT NULL,
    [isDeleted]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (200) NULL,
    [CreatedDate]  DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (200) NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_BUServiceIDBenchMarkMapping] PRIMARY KEY CLUSTERED ([BUSBMMapID] ASC)
);

