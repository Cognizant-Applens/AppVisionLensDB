CREATE TABLE [AVL].[CL_MAS_ResidualReason] (
    [ReasonID]    INT            IDENTITY (1, 1) NOT NULL,
    [ReasonName]  NVARCHAR (MAX) NULL,
    [IsDeleted]   BIT            NULL,
    [CreatedBy]   NVARCHAR (MAX) NULL,
    [CreatedDate] DATETIME       NULL,
    [IsMaster]    BIT            NULL
);

