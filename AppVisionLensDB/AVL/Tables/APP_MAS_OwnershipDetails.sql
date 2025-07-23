CREATE TABLE [AVL].[APP_MAS_OwnershipDetails] (
    [ApplicationTypeID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplicationTypename] NVARCHAR (50) NULL,
    [IsDeleted]           BIT           NULL,
    [CreateDateTime]      DATETIME      NULL,
    [CreatedBY]           NVARCHAR (50) NULL,
    [ModifiedBY]          NVARCHAR (50) NULL,
    [ModifiedDateTime]    DATETIME      NULL,
    CONSTRAINT [PK__APP_MAS___2821511A2612518D] PRIMARY KEY CLUSTERED ([ApplicationTypeID] ASC)
);

