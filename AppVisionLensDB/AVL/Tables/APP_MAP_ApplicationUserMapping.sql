CREATE TABLE [AVL].[APP_MAP_ApplicationUserMapping] (
    [UserApplicationMapID] BIGINT     IDENTITY (1, 1) NOT NULL,
    [UserID]               INT        NOT NULL,
    [ApplicationID]        BIGINT     NOT NULL,
    [IsDeleted]            BIT        NOT NULL,
    [CreatedBy]            NCHAR (10) NOT NULL,
    [CreatedDate]          DATETIME   CONSTRAINT [DF_APP_MAP_ApplicationUserMapping_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NCHAR (10) NULL,
    [ModifiedDate]         DATETIME   NULL,
    CONSTRAINT [PK_APP_MAP_ApplicationUserMapping] PRIMARY KEY CLUSTERED ([UserApplicationMapID] ASC),
    CONSTRAINT [FK_APP_MAP_ApplicationUserMapping_APP_MAS_ApplicationDetails] FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    CONSTRAINT [FK_APP_MAP_ApplicationUserMapping_MAS_LoginMaster] FOREIGN KEY ([UserID]) REFERENCES [AVL].[MAS_LoginMaster] ([UserID])
);

