CREATE TABLE [AVL].[APP_MAP_SubClusterUserMapping] (
    [UserApplicationMapID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [UserID]               NVARCHAR (50) NOT NULL,
    [CustomerId]           BIGINT        NOT NULL,
    [SubClusterID]         BIGINT        NOT NULL,
    [IsDeleted]            BIT           NOT NULL,
    [CreatedBy]            NCHAR (10)    NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_APP_MAP_APP_MAP_SubClusterUserMapping_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NCHAR (10)    NULL,
    [ModifiedDate]         DATETIME      NULL,
    CONSTRAINT [PK_APP_MAP_SubClusterUserMapping] PRIMARY KEY CLUSTERED ([UserApplicationMapID] ASC),
    CONSTRAINT [FK_APP_MAP_SubClusterUserMapping_BusinessClusterMapping] FOREIGN KEY ([SubClusterID]) REFERENCES [AVL].[BusinessClusterMapping] ([BusinessClusterMapID])
);

