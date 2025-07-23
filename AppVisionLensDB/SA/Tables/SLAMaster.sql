CREATE TABLE [SA].[SLAMaster] (
    [SLAMasterId]             INT            IDENTITY (1, 1) NOT NULL,
    [SlaType]                 NVARCHAR (100) NULL,
    [Priority]                NVARCHAR (100) NOT NULL,
    [Severity]                NVARCHAR (100) NULL,
    [ResponseTime]            INT            NULL,
    [RestorationTime]         INT            NULL,
    [SLAMasterApplication_id] BIGINT         NOT NULL,
    [AssignmentGroup]         NVARCHAR (100) NOT NULL,
    [MaximumAdherence]        INT            NULL,
    [MinimumAdherence]        INT            NULL,
    [AmberAlert]              INT            NULL,
    [AhiWeightage]            INT            NOT NULL,
    [EngagementSupport]       NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([SLAMasterId] ASC)
);

