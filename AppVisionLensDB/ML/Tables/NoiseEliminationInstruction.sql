CREATE TABLE [ML].[NoiseEliminationInstruction] (
    [SNo]          INT            IDENTITY (1, 1) NOT NULL,
    [Description]  NVARCHAR (500) NOT NULL,
    [CreatedBy]    NVARCHAR (20)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (20)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([SNo] ASC)
);

