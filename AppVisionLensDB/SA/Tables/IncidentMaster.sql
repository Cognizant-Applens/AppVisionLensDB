CREATE TABLE [SA].[IncidentMaster] (
    [IncidentMasterAssignmentGroup] NVARCHAR (100) NOT NULL,
    [IncidentMasterApplicationId]   BIGINT         NOT NULL,
    [InciddentMasterBusinessArea]   NVARCHAR (100) NOT NULL,
    [IncidentMasterFunctionalGroup] NVARCHAR (100) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([InciddentMasterBusinessArea] ASC)
);

