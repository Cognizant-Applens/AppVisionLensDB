CREATE TABLE [ESA].[BusinessUnits] (
    [BUID]             SMALLINT       NOT NULL,
    [BUName]           NVARCHAR (100) NOT NULL,
    [PracticeCode]     NVARCHAR (70)  NOT NULL,
    [ShortName]        NVARCHAR (30)  NOT NULL,
    [IsActive]         BIT            NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    CONSTRAINT [PK__Business__5D76EB59160F4887] PRIMARY KEY CLUSTERED ([BUID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [UQ__Business__7AC446D218EBB532] UNIQUE NONCLUSTERED ([ShortName] ASC) WITH (FILLFACTOR = 70)
);

