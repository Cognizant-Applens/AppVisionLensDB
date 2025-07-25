﻿CREATE TABLE [AVL].[TK_ProjectForMLClassification] (
    [AutoClassificationDetailsID]   INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]                     BIGINT         NULL,
    [EmployeeID]                    NVARCHAR (50)  NULL,
    [IsAutoClassified]              CHAR (1)       NULL,
    [IsDDAutoClassified]            CHAR (1)       NULL,
    [DDAutoClassificationDate]      CHAR (1)       NULL,
    [AutoClassificationDate]        DATETIME       NULL,
    [InputFileName]                 NVARCHAR (100) NULL,
    [AutoClassificationStatus]      INT            NULL,
    [APIRequestedTime]              DATETIME       NULL,
    [APIRespondedTime]              DATETIME       NULL,
    [OutputFileName]                NVARCHAR (100) NULL,
    [CreatedBy]                     NVARCHAR (100) NULL,
    [CreatedDate]                   DATETIME       NULL,
    [ModifiedBy]                    NVARCHAR (100) NULL,
    [ModifiedDate]                  DATETIME       NULL,
    [IsAutoClassifiedInfra]         CHAR (1)       NULL,
    [IsDDAutoClassifiedInfra]       CHAR (1)       NULL,
    [DDAutoClassificationDateInfra] CHAR (1)       NULL,
    [AutoClassificationDateInfra]   DATETIME       NULL,
    [InputFileNameInfra]            NVARCHAR (100) NULL,
    [OutputFileNameInfra]           NVARCHAR (100) NULL,
    [APIRequestedTimeInfra]         DATETIME       NULL,
    [APIRespondedTimeInfra]         DATETIME       NULL,
    CONSTRAINT [PK_TK_ProjectForMLClassification] PRIMARY KEY CLUSTERED ([AutoClassificationDetailsID] ASC)
);

