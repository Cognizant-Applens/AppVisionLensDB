CREATE TABLE [MS].[MAS_BaseMesureInputType_Master] (
    [BaseMesureInputTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [BaseMesureInputType]   NVARCHAR (50) NULL,
    [IsDeleted]             BIT           NULL,
    CONSTRAINT [PK_BaseMesureInputType_Master] PRIMARY KEY CLUSTERED ([BaseMesureInputTypeID] ASC) WITH (FILLFACTOR = 70)
);

