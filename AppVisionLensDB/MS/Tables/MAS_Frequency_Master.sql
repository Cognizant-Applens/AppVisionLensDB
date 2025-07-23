CREATE TABLE [MS].[MAS_Frequency_Master] (
    [FrequencyID]   INT           IDENTITY (1, 1) NOT NULL,
    [FrequencyName] NVARCHAR (50) NULL,
    [IsDeleted]     BIT           NULL,
    CONSTRAINT [PK_Frequency_Master] PRIMARY KEY CLUSTERED ([FrequencyID] ASC) WITH (FILLFACTOR = 70)
);

