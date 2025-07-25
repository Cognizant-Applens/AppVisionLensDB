﻿CREATE TABLE [ADM].[Project_Sprint_TRN_SP_Velocity] (
    [ProjectSprintVelocityID]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]                     BIGINT          NOT NULL,
    [SprintDetailsID]               INT             NOT NULL,
    [Month]                         TINYINT         NOT NULL,
    [Year]                          SMALLINT        NOT NULL,
    [PoDID]                         INT             NOT NULL,
    [PoDCapacity]                   DECIMAL (18, 2) NOT NULL,
    [VelocityCommitted]             DECIMAL (18, 2) NOT NULL,
    [VelocityDelivered]             DECIMAL (18, 2) NOT NULL,
    [WorkItemSize]                  DECIMAL (18, 2) NOT NULL,
    [SprintDuration]                SMALLINT        NOT NULL,
    [BenchmarkVelocity]             DECIMAL (18, 2) NOT NULL,
    [NoofResources]                 DECIMAL (18, 2) NOT NULL,
    [EachResourcesDeliverable]      DECIMAL (18, 2) NOT NULL,
    [EachResourcePerDayDeliverable] DECIMAL (18, 2) NOT NULL,
    [Outlier]                       BIT             NOT NULL,
    [IsDeleted]                     BIT             DEFAULT ((0)) NOT NULL,
    [CreatedBy]                     NVARCHAR (50)   DEFAULT ('System') NOT NULL,
    [CreatedDate]                   DATETIME        DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                    NVARCHAR (50)   NULL,
    [ModifiedDate]                  DATETIME        NULL,
    CONSTRAINT [PK_ProjectSprintPODVelocityID] PRIMARY KEY CLUSTERED ([ProjectSprintVelocityID] ASC)
);

