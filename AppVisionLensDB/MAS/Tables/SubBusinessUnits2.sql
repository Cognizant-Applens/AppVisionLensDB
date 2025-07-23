CREATE TABLE [MAS].[SubBusinessUnits2] (
    [SBU2ID]       INT            IDENTITY (1, 1) NOT NULL,
    [SBU2Name]     NVARCHAR (100) NOT NULL,
    [ESASBU2ID]    NVARCHAR (50)  NOT NULL,
    [SBU1ID]       INT            NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_SubBusinessUnits2_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_SubBusinessUnits2] PRIMARY KEY CLUSTERED ([SBU2ID] ASC),
    CONSTRAINT [FK_SubBusinessUnits2_SubBusinessUnits1] FOREIGN KEY ([SBU1ID]) REFERENCES [MAS].[SubBusinessUnits1] ([SBU1ID]),
    CONSTRAINT [UK_SubBusinessUnits2_ESASBU2ID] UNIQUE NONCLUSTERED ([ESASBU2ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SubBusinessUnits2]
    ON [MAS].[SubBusinessUnits2]([IsDeleted] ASC)
    INCLUDE([SBU2Name]);

