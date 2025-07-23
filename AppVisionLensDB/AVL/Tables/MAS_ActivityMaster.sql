CREATE TABLE [AVL].[MAS_ActivityMaster] (
    [ActivityID]   INT           IDENTITY (1, 1) NOT NULL,
    [ActivityName] NVARCHAR (50) NULL,
    [ActivityDesc] NVARCHAR (50) NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedBy]    NVARCHAR (50) NULL,
    [CreateDate]   DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_ActivityMaster] PRIMARY KEY CLUSTERED ([ActivityID] ASC) WITH (FILLFACTOR = 70)
);

