CREATE TABLE [MAS].[SubBusinessUnits1] (
    [SBU1ID]         INT            IDENTITY (1, 1) NOT NULL,
    [SBU1Name]       NVARCHAR (100) NOT NULL,
    [ESASBU1ID]      NVARCHAR (50)  NOT NULL,
    [BusinessUnitID] INT            NOT NULL,
    [IsDeleted]      BIT            CONSTRAINT [DF_SubBusinessUnits1_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]      NVARCHAR (50)  NOT NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME       NULL,
    CONSTRAINT [PK_SubBusinessUnits1] PRIMARY KEY CLUSTERED ([SBU1ID] ASC),
    CONSTRAINT [FK_SubBusinessUnits1_BusinessUnits] FOREIGN KEY ([BusinessUnitID]) REFERENCES [MAS].[BusinessUnits] ([BusinessUnitID]),
    CONSTRAINT [UK_SubBusinessUnits1_ESASBU1ID] UNIQUE NONCLUSTERED ([ESASBU1ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SubBusinessUnits1]
    ON [MAS].[SubBusinessUnits1]([IsDeleted] ASC)
    INCLUDE([SBU1Name], [BusinessUnitID]);

