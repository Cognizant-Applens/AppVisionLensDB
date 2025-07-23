CREATE TYPE [PP].[TVP_BestPracticeDetails] AS TABLE (
    [KEDBOwnedId]          INT            NULL,
    [ExternalKEDB]         NVARCHAR (250) NULL,
    [IsApplensAsKEDB]      BIT            NULL,
    [IsReqBaselined]       BIT            NULL,
    [IsAcceptanceDefined]  BIT            NULL,
    [ScopeChangeControlId] INT            NULL,
    [IsVelocityMeasured]   BIT            NULL,
    [UOM]                  NVARCHAR (250) NULL,
    [IsDevOrMainByCog]     BIT            NULL,
    [IntegratedServiceId]  INT            NULL,
    [StatusReportId]       INT            NULL,
    [ExplicitRisks]        NVARCHAR (250) NULL);

