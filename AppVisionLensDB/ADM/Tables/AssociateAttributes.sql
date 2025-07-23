CREATE TABLE [ADM].[AssociateAttributes] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [UserId]       INT            NOT NULL,
    [PODDetailID]  BIGINT         NULL,
    [CCARole]      BIGINT         NULL,
    [IsDeleted]    BIT            NULL,
    [CreatedDate]  DATETIME       NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [UserCapacity] DECIMAL (5, 2) NULL,
    CONSTRAINT [PK_ADM.AssociateAttributes] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PodId] FOREIGN KEY ([PODDetailID]) REFERENCES [PP].[Project_PODDetails] ([PODDetailID]),
    CONSTRAINT [FK_UserId] FOREIGN KEY ([UserId]) REFERENCES [AVL].[MAS_LoginMaster] ([UserID])
);

