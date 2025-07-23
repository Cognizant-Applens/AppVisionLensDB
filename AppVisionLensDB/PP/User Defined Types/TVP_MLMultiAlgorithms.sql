CREATE TYPE [PP].[TVP_MLMultiAlgorithms] AS TABLE (
    [AlgorithmId] INT      NOT NULL,
    [Preference]  SMALLINT NOT NULL,
    [IsSelected]  BIT      NOT NULL);

