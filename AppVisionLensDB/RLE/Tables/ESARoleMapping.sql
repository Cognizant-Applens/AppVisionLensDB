CREATE TABLE [RLE].[ESARoleMapping] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [ESARoleName]       NVARCHAR (50) NOT NULL,
    [ApplensRoleID]     INT           NOT NULL,
    [GroupID]           INT           NOT NULL,
    [AccessLevelTypeID] INT           NOT NULL,
    [IsDeleted]         BIT           CONSTRAINT [DF_ESARoleMapping_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      NVARCHAR (50) NULL,
    CONSTRAINT [PK_ESARoleMapping] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ESARoleMapping_RLE_AccessLevelTypes] FOREIGN KEY ([AccessLevelTypeID]) REFERENCES [MAS].[RLE_AccessLevelTypes] ([AccessLevelTypeID]),
    CONSTRAINT [FK_ESARoleMapping_RLE_Groups] FOREIGN KEY ([GroupID]) REFERENCES [MAS].[RLE_Groups] ([GroupID]),
    CONSTRAINT [FK_ESARoleMapping_RLE_Roles] FOREIGN KEY ([ApplensRoleID]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID])
);

