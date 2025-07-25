﻿CREATE TABLE [MS].[MPS_STAGING_TABLE_EFORM_VIEW] (
    [ENTERPRISEID]              INT             NOT NULL,
    [OWNERTYPE]                 NVARCHAR (3)    NOT NULL,
    [OWNERID]                   INT             NOT NULL,
    [ITEMTYPE]                  NVARCHAR (5)    NOT NULL,
    [ITEMID]                    INT             NOT NULL,
    [CM_NAME]                   NVARCHAR (3)    NOT NULL,
    [CM_DESCRIPTION]            NVARCHAR (MAX)  NULL,
    [CM_OVERALLSTATUS]          NVARCHAR (4)    NOT NULL,
    [CM_SEQNUMBER]              INT             NOT NULL,
    [CM_WBSCODE]                INT             NULL,
    [CM_CONTAINERTYPE]          INT             NULL,
    [CM_CONTAINERID]            INT             NULL,
    [CM_ITEMCODE]               NVARCHAR (4)    NOT NULL,
    [CM_ACCESSCONTROL]          INT             NOT NULL,
    [CM_CREATEDBY]              INT             NULL,
    [CM_CREATIONDATE]           INT             NULL,
    [CM_DATECLOSED]             INT             NULL,
    [CM_CFMSTATUS]              NVARCHAR (2)    NOT NULL,
    [CM_CHECKINCHECKOUTBY]      INT             NULL,
    [CM_CHECKINCHECKOUTON]      INT             NULL,
    [CM_DATEIDENTIFIED]         INT             NULL,
    [CM_DUEDATE]                INT             NULL,
    [CM_PHASEID]                INT             NULL,
    [CM_ETVX]                   INT             NULL,
    [CM_PRIORITY]               INT             NULL,
    [CM_RELEASE]                INT             NULL,
    [DN_MPSSTID]                INT             NOT NULL,
    [DN_PROJECTNAME]            NVARCHAR (200)  NULL,
    [DN_PROJECTID]              NVARCHAR (50)   NOT NULL,
    [DN_SEGMENTNAME]            NVARCHAR (200)  NULL,
    [DN_TABLENAME]              NVARCHAR (200)  NULL,
    [DN_BASELINEDATE]           DATETIME        NULL,
    [DN_SERVICEOFFERINGLEVEL3]  NVARCHAR (200)  NULL,
    [DN_SERVICEOFFERINGLEVEL2]  NVARCHAR (200)  NULL,
    [DN_METRICNAME]             NVARCHAR (200)  NULL,
    [DN_MANDATORY]              NVARCHAR (200)  NULL,
    [DN_GOALTYPE]               NVARCHAR (200)  NULL,
    [DN_UOM]                    NVARCHAR (200)  NULL,
    [DN_METRICTYPE]             NVARCHAR (200)  NULL,
    [DN_SUPPORTCATEGORY]        NVARCHAR (200)  NULL,
    [DN_PRIORITY]               NVARCHAR (200)  NULL,
    [DN_TECHNOLOGY]             NVARCHAR (200)  NULL,
    [DN_GOALLEVEL]              NVARCHAR (200)  NULL,
    [DN_GOAL]                   NVARCHAR (200)  NULL,
    [DN_INCEPTION]              NVARCHAR (200)  NULL,
    [DN_FUNCTIONAL]             NVARCHAR (200)  NULL,
    [DN_PERFORMING]             NVARCHAR (200)  NULL,
    [DN_BIC]                    NVARCHAR (200)  NULL,
    [DN_SLAWITHFINANCIALIMPACT] NVARCHAR (200)  NULL,
    [DN_MINIMUMSERVICETARGET]   NVARCHAR (200)  NULL,
    [DN_EXPECTEDSERVICETARGET]  NVARCHAR (200)  NULL,
    [DN_CPKGOAL]                NVARCHAR (200)  NULL,
    [DN_APPLICABILITY]          NVARCHAR (200)  NULL,
    [DN_UNIQUEKEY]              NVARCHAR (2000) NULL,
    [DN_CUSTOMMETRICOPERATIONA] NVARCHAR (200)  NULL,
    [DN_CUSTOMMETRICORGLEVELMA] NVARCHAR (200)  NULL,
    [DN_PROJECTSTARTDATE]       DATETIME        NULL,
    [DN_OTHER4]                 DATETIME        NULL,
    [DN_OTHER5]                 INT             NULL,
    [DN_OTHER6]                 INT             NULL,
    [DN_OWNERID]                INT             NOT NULL
);

