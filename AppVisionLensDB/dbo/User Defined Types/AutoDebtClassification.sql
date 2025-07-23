CREATE TYPE [dbo].[AutoDebtClassification] AS TABLE (
    [EsaProjectID]                INT            NOT NULL,
    [ClassificationMode]          NVARCHAR (MAX) NULL,
    [ClassificationEffectiveDate] DATETIME       NULL,
    [DebtControlDate]             DATETIME       NULL);

