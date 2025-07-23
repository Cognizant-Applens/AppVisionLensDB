/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================  
-- Author: Devika 
-- Create date: 11 June 2018
-- Description: Migration of ITSM Configuration Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC SP_DataMigration_ITSMConfiguration '1205421'
-- ================================================================================= 
-- EXEC SP_DataMigration_ITSMConfiguration 1230256,'1000234601'  select * from DataMigration_Projects (nolock) where esa_accountid = 1200020

CREATE PROC [dbo].[SP_DataMigration_ITSMConfiguration]
(
	@AccountID BIGINT, -- ESA ACCOUNT ID
	@ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
)
AS
BEGIN

---------- Get all projects or specific project(s) for the Accounts ----------
SELECT
	Item AS ESAProjectID INTO #ESAProjectIds
FROM dbo.Split(@ESAProjectIDs, ',')

DECLARE @ProjectDetailsITSM TABLE(AccountID INT,
ProjectID INT,
ProjectName NVARCHAR(50),
EsaProjectID NVARCHAR(100))

INSERT INTO @ProjectDetailsITSM
	SELECT
		DA.AccountID AS AccountID
		,PM.ProjectID
		,PM.ProjectName
		,PM.EsaProjectID
	FROM AVMDART.[MAP].[DeptAcctMapping](NOLOCK) DA
	JOIN AVL.Customer(NOLOCK) cust
		ON cust.ESA_AccountID = DA.AccountID
		--AND cust.IsDeleted = 0
	JOIN AVMDART.MAS.ProjectMaster(NOLOCK) PM
		ON 
		DA.AccountID = @AccountID
		AND
		 PM.DeptAccountID = DA.DeptAccountID
		AND DA.IsDeleted = 'N' 
		AND PM.IsDeleted = 'N'
	JOIN [AVL].[MAS_ProjectMaster](NOLOCK) APLPM
		ON APLPM.EsaProjectID = PM.EsaProjectID
		AND APLPM.IsDeleted = 0
	WHERE @ESAProjectIDs IS NULL
	OR PM.EsaProjectID IN (SELECT
			ESAProjectID
		FROM #ESAProjectIds)

		select * from @ProjectDetailsITSM

DROP TABLE #ESAProjectIds

------------------------------------------------------------------------------------------
BEGIN TRY

---------------------------------------- HOME ----------------------------------------
PRINT 'Home Update'

UPDATE prjapp
SET	prjapp.ITSMID = 14
	,prjapp.ITSMConfiguration = 'M'
FROM AVL.MAS_ProjectMaster(NOLOCK) prjapp
JOIN @ProjectDetailsITSM prjdet
	ON prjdet.EsaProjectID = prjapp.EsaProjectID

PRINT 'End of Home'

---------------------------------------- COLUMN MAPPING ----------------------------------------
-- PRINT 'Start of Column Mapping'

SELECT DISTINCT
	col.SSIScmID AS SSIScmID
	,prjapp.ProjectID AS ProjectID
	,col3.name AS ServiceDartColumn
	,col.ServiceDartColumn AS ProjectColumn
	,CASE
		WHEN col.IsDeleted = 'N' OR
			col.IsDeleted IS NULL THEN 0
		WHEN col.IsDeleted = 'Y' THEN 1
	END AS IsDeleted
	, -- Is Deleted
	GETDATE() AS CreatedDateTime
	, -- Created Date Time
	'Migrated' AS CreatedBy
	,NULL AS ModifiedDateTime
	, -- Modified Date Time
	NULL AS ModifiedBy
	, -- Modified By
	col.SOURCEINDEX AS SOURCEINDEX
	,col.DESTINATIONINDEX AS DESTINATIONINDEX INTO #Temp
FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) col
JOIN AVMDART.MAS.Columnname(NOLOCK) col2
	ON col.ProjectColumn = col2.name
	AND col2.Isdeleted = 'N'
JOIN AVL.ITSM_MAS_Columnname(NOLOCK) col3
	ON REPLACE(col3.name, ' ', '') = replace(col2.name,' ','')
	AND col3.Isdeleted = 0
JOIN @ProjectDetailsITSM prjdet
	ON prjdet.ProjectID = col.ProjectID
JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
	ON prjapp.EsaProjectID = prjdet.EsaProjectID
	AND prjapp.IsDeleted = 0
LEFT JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) appcol
	ON appcol.ProjectID = prjapp.ProjectID
	AND appcol.ServiceDartColumn = col3.name
	AND appcol.ProjectColumn = col.ServiceDartColumn
WHERE col.IsDeleted = 'N'
AND appcol.ProjectID IS NULL
ORDER BY col.SSIScmID ASC

select B.* INTO #TempRes FROM( 

SELECT * from #Temp 
UNION
SELECT
col.SSIScmID AS SSIScmID
       ,prjapp.ProjectID AS ProjectID
       ,col3.name AS ServiceDartColumn
       ,col.ServiceDartColumn AS ProjectColumn
       ,CASE
              WHEN col.IsDeleted = 'N' OR
                     col.IsDeleted IS NULL THEN 0
              WHEN col.IsDeleted = 'Y' THEN 1
       END AS IsDeleted
       , -- Is Deleted
       GETDATE() AS CreatedDateTime
       , -- Created Date Time
       'Migrated' AS CreatedBy
       ,NULL AS ModifiedDateTime
       , -- Modified Date Time
       NULL AS ModifiedBy
       , -- Modified By
       col.SOURCEINDEX AS SOURCEINDEX
       ,col.DESTINATIONINDEX AS DESTINATIONINDEX 
       --INTO #Tempres
  FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) col
JOIN @ProjectDetailsITSM prjdet
       ON prjdet.ProjectID = col.ProjectID
       JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
       ON prjapp.EsaProjectID = prjdet.EsaProjectID
       AND prjapp.IsDeleted = 0
       JOIN AVL.ITSM_MAS_Columnname(NOLOCK) col3
       on col3.name='Resolution Remarks'
LEFT JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) appcol
       ON appcol.ProjectID = prjapp.ProjectID
       AND appcol.ServiceDartColumn = col3.name
       AND appcol.ProjectColumn = col.ServiceDartColumn
WHERE col.IsDeleted = 'N' and col.projectcolumn='Resolution Remarks'
AND appcol.ProjectID IS NULL
)
as B
--drop table  #Tempcolumn



SELECT
       A.* INTO #Tempcolumn
FROM (SELECT DISTINCT
              *
       FROM #TempRes UNION
       
       SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 28
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 79
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL UNION SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 6
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 37
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL UNION SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 30
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 41
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL UNION SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 18
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 89
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL UNION SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 49
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 52
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL UNION SELECT DISTINCT
              ssis.ssiscmid AS SSIScmID
              ,APPPM.ProjectID AS ProjectID
              ,APPMAS.name AS ServiceDartColumn
              ,ssis.servicedartcolumn AS ProjectColumn
              ,CASE
                     WHEN ssis.IsDeleted = 'N' OR
                           ssis.IsDeleted IS NULL THEN 0
                     WHEN ssis.IsDeleted = 'Y' THEN 1
              END AS IsDeleted
              ,GETDATE() AS CreatedDateTime
              ,'Migrated' AS CreatedBy
              ,NULL AS ModifiedDateTime
              ,NULL AS ModifiedBy
              ,ssis.sourceindex AS SOURCEINDEX
              ,ssis.DESTINATIONINDEX AS DESTINATIONINDEX
       FROM AVMDART.PRJ.SSISColumnMapping(NOLOCK) ssis 
       JOIN AVMDART.MAS.Columnname(NOLOCK) COL
              ON COL.name = ssis.PROJECTCOLUMN
              AND COL.ColID = 10
       JOIN @ProjectDetailsITSM pd
              ON pd.ProjectID = ssis.projectid
       JOIN AVL.MAS_ProjectMaster(NOLOCK) APPPM
              ON APPPM.EsaProjectID = pd.EsaProjectID
       LEFT JOIN AVL.ITSM_MAS_Columnname(NOLOCK) APPMAS
              ON APPMAS.ColID = 1004
       LEFT JOIN #TempRes SIIS
              ON SIIS.ProjectID = APPPM.ProjectID
              AND SIIS.ServiceDartColumn = APPMAS.name
       WHERE SIIS.ProjectID IS NULL) AS A


INSERT INTO AVL.ITSM_PRJ_SSISColumnMapping (ProjectID,
ServiceDartColumn,
ProjectColumn,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
SOURCEINDEX,
DESTINATIONINDEX)

	SELECT
		tmp.ProjectID
		,tmp.ServiceDartColumn
		,tmp.ProjectColumn
		,tmp.IsDeleted
		,tmp.CreatedDateTime
		,tmp.CreatedBy
		,tmp.ModifiedDateTime
		,tmp.ModifiedBy
		,tmp.SOURCEINDEX
		,tmp.DESTINATIONINDEX
	FROM #Tempcolumn tmp
	LEFT JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) appcol
		ON appcol.ProjectID = tmp.ProjectID
		AND appcol.ServiceDartColumn = tmp.ServiceDartColumn
		AND appcol.ProjectColumn = tmp.ProjectColumn
	WHERE appcol.ProjectID IS NULL
	ORDER BY tmp.SSIScmID


-- PRINT 'Start of Excel Column Mapping'
DECLARE @Projectid BIGINT
SELECT
	@Projectid = prjapp.ProjectID
FROM AVL.MAS_ProjectMaster(NOLOCK) prjapp

JOIN @ProjectDetailsITSM prjdet
	ON prjdet.ESAProjectID = prjapp.EsaProjectID
	AND prjapp.IsDeleted = 0
INSERT INTO AVL.ITSM_PRJ_SSISExcelColumnMapping (ProjectID,
ServiceDartColumn,
ProjectColumn,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY)
	SELECT DISTINCT
		@Projectid
		,CL.name

		,NULL
		,0
		, -- Is Deleted
		GETDATE()
		, -- Created Date Time
		'Migrated'
		,NULL
		, -- Modified Date Time
		NULL -- Modified By
	FROM AVL.ITSM_MAS_Columnname CL
	LEFT JOIN AVL.ITSM_PRJ_SSISExcelColumnMapping(NOLOCK) appcol
		ON appcol.ProjectID = @Projectid
		AND appcol.ServiceDartColumn = CL.name
	WHERE cl.name
	NOT IN (SELECT
			SCL.ServiceDartColumn
		FROM AVL.ITSM_PRJ_SSISColumnMapping SCL
		WHERE SCL.ProjectID = @Projectid)
	AND cl.Isdeleted = 0
	AND appcol.ProjectID IS NULL

--UPDATE APPSEC set APPSEC.ProjectColumn=''

DECLARE @ssisExcelColumnMapping TABLE(ID BIGINT IDENTITY (1, 1),
SERVICEDARTColumn NVARCHAR(MAX),
ProjectID BIGINT)

INSERT INTO @ssisExcelColumnMapping (SERVICEDARTColumn, ProjectID)
	SELECT
		sec.ServiceDartColumn
		,PM.ProjectID
	FROM AVMDART.PRJ.SSISExcelColumnMapping SEC
	JOIN @ProjectDetailsITSM PD
		ON PD.ProjectID = SEC.ProjectID
	JOIN AVL.MAS_ProjectMaster PM
		ON PM.EsaProjectID = PD.EsaProjectID

	WHERE sec.ServiceDartColumn IS NOT NULL
--SELECT * FROM @ssisExcelColumnMapping
DECLARE @mincount BIGINT, @MAXcount BIGINT
, @COUNTFORSSIS BIGINT
= (SELECT
		COUNT(*)
	FROM AVL.ITSM_PRJ_SSISExcelColumnMapping
	WHERE ProjectID = @Projectid)
SET @MAXcount = (SELECT
		MAX(ID)
	FROM @ssisExcelColumnMapping)
PRINT 'MAXcount' + CAST(@MAXcount AS NVARCHAR(MAX))
SET @mincount = (SELECT
		MIN(ID)
	FROM @ssisExcelColumnMapping)
DECLARE @I BIGINT = @mincount
DECLARE @SSIS BIGINT = (SELECT
		MIN(SSIScmID)
	FROM AVL.ITSM_PRJ_SSISExcelColumnMapping
	WHERE ProjectID = @Projectid)
,
@SSISMAX BIGINT = (SELECT
		MAX(SSIScmID)
	FROM AVL.ITSM_PRJ_SSISExcelColumnMapping
	WHERE ProjectID = @Projectid)
WHILE (@mincount <= @MAXcount AND @mincount <= @COUNTFORSSIS) BEGIN
UPDATE EXCEL
SET EXCEL.ProjectColumn = (SELECT
		SERVICEDARTColumn
	FROM @ssisExcelColumnMapping
	WHERE id = @mincount)
--SELECT EXCEL.SSIScmID
----,SSIS.SERVICEDARTColumn
--,EXCEL.ProjectColumn
FROM AVL.ITSM_PRJ_SSISExcelColumnMapping EXCEL
WHERE EXCEL.SSIScmID = @SSIS
AND EXCEL.ProjectID = @Projectid
SET @SSIS = @SSIS + 1;
SET @mincount = @mincount + 1

END
IF (@mincount < @MAXcount) BEGIN

INSERT INTO AVL.ITSM_PRJ_SSISExcelColumnMapping 
(ServiceDartColumn, ProjectColumn, ProjectID, CreatedDateTime, CreatedBY)
	SELECT
		NULL
		,ssisextra.SERVICEDARTColumn
		,ssisextra.ProjectID
		,GETDATE()
		,'Migrated'
	FROM @ssisExcelColumnMapping
	ssisextra
	LEFT JOIN AVL.ITSM_PRJ_SSISExcelColumnMapping ASSEXCEL
		ON ASSEXCEL.ProjectID = ssisextra.ProjectID
		AND ssisextra.SERVICEDARTColumn = ASSEXCEL.ProjectColumn
	WHERE id >= @mincount
	AND ASSEXCEL.ProjectID IS NULL

END




-- PRINT 'End of Column Mapping'

----------------------------------- Project Service Activity ----------------------------------
INSERT INTO AVL.TK_PRJ_ProjectServiceActivityMapping (ServiceMapID,
ProjectID,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
IsHidden,
EffectiveDate,
IsMainspringData)
	SELECT DISTINCT
		sa.ServiceMappingID
		,prjapp.ProjectID
		,CASE
			WHEN prjsev.IsDeleted = 'N' OR
				prjsev.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		,GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,prjsev.IsHidden
		,prjsev.EffectiveDate
		,prjsev.IsMainSpringData
	FROM AVMDART.[MAP].[ServiceProjectMapping](NOLOCK) prjsev
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjsev.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) sa
		ON sa.ServiceName = prjsev.ServiceName
		AND sa.ActivityName = prjsev.ActivityName
	--LEFT JOIN DataMigration_SelfConfiguredMapping_Transformation (NOLOCK) SAT
	--	ON SAT.DARTServiceName = prjsev.ServiceName AND SAT.DARTActivityName = prjsev.ActivityName
	--LEFT JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SCAM
	--	ON SCAM.ServiceName = SAT.AppLensServiceName AND SCAM.ActivityName = SAT.AppLensActivityName
	LEFT JOIN AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) psam
		ON psam.ProjectID = prjapp.ProjectID
		AND psam.ServiceMapID = sa.ServiceMappingID
	WHERE prjsev.IsDeleted = 'N'
	AND psam.ProjectID IS NULL

UPDATE PSAM
SET PSAM.IsMainspringData = NULL
FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM
	ON SAM.ServiceMappingID = PSAM.ServiceMapID
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
	ON PM.ProjectID = PSAM.ProjectID
JOIN @ProjectDetailsITSM PD
	ON PD.EsaProjectID = PM.EsaProjectID
WHERE SAM.ServiceTypeID <> 4
AND pm.IsMainSpringConfigured = 'Y'


UPDATE PSAM
SET PSAM.IsHidden = 1
FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM
	ON SAM.ServiceMappingID = PSAM.ServiceMapID
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
	ON PM.ProjectID = PSAM.ProjectID
JOIN @ProjectDetailsITSM PD
	ON PD.EsaProjectID = PM.EsaProjectID
WHERE PSAM.IsMainspringData IS NULL
AND pm.IsMainSpringConfigured = 'Y'
AND SAM.ServiceTypeID = 4

---------------------------------------- TICKET TYPE ----------------------------------------
PRINT 'Start of Ticket Type'

---- 1. Ticket Type Mapping Table

INSERT INTO AVL.TK_MAP_TicketTypeMapping (TicketType,
AVMTicketType,
ProjectID,
DebtConsidered,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
IsDefaultTicketType,
TicketTypeName)
	SELECT DISTINCT
		tt.TicketType
		,app.TicketTypeID
		,prjapp.ProjectID
		,NULL
		,CASE
			WHEN tt.IsDeleted = 'N' OR
				tt.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		, -- Is Deleted
		GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,tt.IsDefaultTicketType
		,NULL
	FROM AVMDART.[PRJ].[TicketTypeMapping](NOLOCK) tt
	JOIN AVMDART.MAS.TicketType(NOLOCK) mas
		ON mas.TicketTypeID = tt.AVMTicketType
		AND mas.IsDeleted = 'N'
	JOIN AVL.TK_MAS_TicketType(NOLOCK) app
		ON app.TicketTypeName = mas.TicketTypeName
		AND app.IsDeleted = 0
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = tt.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) ttm
		ON ttm.ProjectID = prjapp.ProjectID
		AND ttm.TicketType = tt.TicketType
		AND ttm.AVMTicketType = app.TicketTypeID
	WHERE ttm.ProjectID IS NULL


PRINT 'End of Ticket Type'

---- 2. Ticket Type Service Mapping Table

PRINT 'Start of Ticket Type Service'

DECLARE @TicketTypeService TABLE(ProjectID BIGINT,
TicketTypeMappingID BIGINT,
ServiceID INT,
IsDART INT,
IsDeleted BIT,
CreatedDateTime DATETIME,
CreatedBY NVARCHAR(400),
ModifiedDateTime DATETIME,
ModifiedBY NVARCHAR(100),
EffectiveDate DATETIME)

INSERT INTO @TicketTypeService (ProjectID,
TicketTypeMappingID,
ServiceID,
IsDART,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
EffectiveDate)
	(
	SELECT DISTINCT
		prjapp.ProjectID
		,map.TicketTypeMappingID
		,ttser.ServiceID
		, -- Check
		NULL
		,CASE
			WHEN ttser.IsDeleted = 'N' OR
				ttser.IsDeleted IS NULL THEN 0
			WHEN ttser.IsDeleted = 'Y' THEN 1
		END
		,GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,ttser.EffectiveDate
	FROM AVMDART.PRJ.TicketTypeServiceMapping(NOLOCK) ttser
	JOIN AVMDART.[PRJ].[TicketTypeMapping](NOLOCK) ttmavm
		ON ttmavm.TicketTypeMappingID = ttser.AVMTicketTypeID
	JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) map
		ON map.TicketType = ttmavm.TicketType
	JOIN AVL.TK_MAS_TicketType(NOLOCK) app
		ON map.AVMTicketType = app.TicketTypeID
	JOIN AVMDART.MAS.TicketType(NOLOCK) mas
		ON app.TicketTypeName = mas.TicketTypeName
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = ttser.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND map.Projectid = prjapp.ProjectID
		AND prjapp.IsDeleted = 0 UNION SELECT DISTINCT
		prjapp.ProjectID
		,map.TicketTypeMappingID
		,dart.ServiceID
		, -- Check
		NULL
		,CASE
			WHEN dart.IsDeleted = 'N' OR
				dart.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		,GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,dart.EffectiveDate
	FROM AVMDART.PRJ.DARTTicketTypeServiceMapping(NOLOCK) dart
	JOIN AVMDART.[PRJ].[TicketTypeMapping](NOLOCK) ttmavm
		ON ttmavm.TicketTypeMappingID = dart.AVMTicketTypeID
	JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) map
		ON map.TicketType = ttmavm.TicketType
	JOIN AVL.TK_MAS_TicketType(NOLOCK) app
		ON map.AVMTicketType = app.TicketTypeID
	JOIN AVMDART.MAS.TicketType(NOLOCK) mas
		ON app.TicketTypeName = mas.TicketTypeName
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = dart.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND map.Projectid = prjapp.ProjectID
		AND prjapp.IsDeleted = 0
	)

INSERT INTO AVL.TK_MAP_TicketTypeServiceMapping (ProjectID,
TicketTypeMappingID,
ServiceID,
IsDART,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
EffectiveDate)
	SELECT DISTINCT
		tts.ProjectID
		,tts.TicketTypeMappingID
		,tts.ServiceID
		,tts.IsDART
		,tts.IsDeleted
		,tts.CreatedDateTime
		,tts.CreatedBY
		,tts.ModifiedDateTime
		,tts.ModifiedBY
		,tts.EffectiveDate
	FROM @TicketTypeService tts
	LEFT JOIN AVL.TK_MAP_TicketTypeServiceMapping(NOLOCK) ttsm
		ON ttsm.ProjectID = tts.ProjectID
		AND ttsm.TicketTypeMappingID = tts.TicketTypeMappingID
		AND ttsm.ServiceID = tts.ServiceID
		AND ttsm.IsDART = tts.IsDART
	WHERE ttsm.ProjectID IS NULL

PRINT 'End of Ticket Type Service'

---------------------------------------- PRIORITY MANAGEMENT ----------------------------------------

PRINT 'Start of Priority Management'

INSERT INTO AVL.TK_MAP_PriorityMapping (PriorityName,
ProjectID,
IsDeleted,
CreatedDateTime,
CreatedBY,
ModifiedDateTime,
ModifiedBY,
POSITION,
IsDefaultPriority,
MainspringProjectPriorityID,
PriorityID)
	SELECT DISTINCT
		dartpm.PriorityName
		,prjapp.ProjectID
		,CASE
			WHEN dartpm.IsDeleted = 'N' OR
				dartpm.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		,GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,dartpm.POSITION
		,dartpm.IsDefaultPriority
		,NULL
		,apppm.PriorityID
	FROM AVMDART.PRJ.PriorityMaster(NOLOCK) dartpm
	JOIN DBO.DataMigration_DartAppLensPriorityNameMapping(NOLOCK) dapnm
		ON dapnm.ProjectID = dartpm.ProjectID
		AND dapnm.DartPriorityName = dartpm.PriorityName
	JOIN AVL.TK_MAS_Priority(NOLOCK) apppm
		ON apppm.PriorityName = dapnm.AppLensPriorityName
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = dartpm.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_PriorityMapping(NOLOCK) avlpmap
		ON avlpmap.ProjectID = prjapp.ProjectID
		AND avlpmap.PriorityName = dartpm.PriorityName
	WHERE avlpmap.ProjectID IS NULL


PRINT 'End of Priority Management'

---------------------------------------- SEVERITY MAPPING ----------------------------------------

PRINT 'Start of Severity'

INSERT INTO AVL.TK_MAP_SeverityMapping (SeverityID,
SeverityName,
ProjectID,
IsDeleted,
CreatedDateTime,
CreatedBy,
ModifiedDateTime,
ModifiedBy,
IsFixedSource,
IsDefaultSeverity,
Position)
	SELECT DISTINCT
		appdart.SeverityID
		,prjsev.SeverityName
		,prjapp.ProjectID
		,CASE
			WHEN prjsev.IsDeleted = 'N' OR
				prjsev.IsDeleted IS NULL THEN 0
			ELSE 1
		END AS IsDeleted
		,GETDATE() AS CreatedDateTime
		,'Migrated'
		,NULL AS ModifiedDateTime
		,NULL AS ModifiedBy
		,prjsev.IsFixedSource
		,prjsev.IsDefaultSeverity
		,prjsev.Position
	FROM AVMDART.PRJ.ProjectSeverityDetails(NOLOCK) prjsev
	LEFT JOIN AVMDART.MAS.DARTSeverityMaster(NOLOCK) dartsev
		ON prjsev.DARTSeverityID = dartsev.DARTSeverityID
	LEFT JOIN AVL.TK_MAS_Severity(NOLOCK) appdart
		ON appdart.SeverityName = dartsev.DARTSeverity
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjsev.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_SeverityMapping(NOLOCK) appsm
		ON appsm.ProjectID = prjapp.ProjectID
		AND appsm.SeverityID = appdart.SeverityID
		AND appsm.SeverityName = prjsev.SeverityName
	WHERE appsm.ProjectID IS NULL

PRINT 'End of Severity'

---------------------------------------- TICKET STATUS ----------------------------------------

PRINT 'Start of Ticket Status'

INSERT INTO [AVL].[TK_MAP_ProjectStatusMapping] (StatusName,
TicketStatus_ID,
ProjectID,
IsDeleted,
CreatedDate,
CreatedBy,
ModifiedDate,
ModifiedBy,
IsDefaultTicketStatus)
	SELECT DISTINCT
		prjstatus.StatusName
		,appdart.DARTStatusID
		,prjapp.ProjectID
		,CASE
			WHEN prjstatus.IsDeleted = 'N' OR
				prjstatus.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		,GETDATE()
		,'Migrated'
		,NULL
		,NULL
		,prjstatus.IsDefaultTicketStatus
	FROM AVMDART.PRJ.StatusMaster(NOLOCK) prjstatus
	JOIN AVMDART.[MAS].[DARTStatus](NOLOCK) dart
		ON prjstatus.DARTStatusId = dart.DARTSatusId
	JOIN [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) appdart
		ON appdart.DARTStatusName = dart.DartStatusName
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjstatus.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN [AVL].[TK_MAP_ProjectStatusMapping](NOLOCK) apppsm
		ON apppsm.ProjectID = prjapp.ProjectID
		AND apppsm.StatusName = prjstatus.StatusName
		AND apppsm.TicketStatus_ID = appdart.DARTStatusID
	WHERE apppsm.ProjectID IS NULL

PRINT 'End of Ticket Status'

---------------------------------------- CAUSE CODE ----------------------------------------

PRINT 'Start of Cause Code'

INSERT INTO AVL.DEBT_MAP_CauseCode (CauseCode,
CauseStatusID,
ProjectID,
IsHealConsidered,
IsDeleted,
CreatedBy,
CreatedDate,
ModifiedBy,
ModifiedDate)
	SELECT DISTINCT
		prjcc.CauseCode
		,NULL
		,prjapp.ProjectID
		,prjcc.IsHealConsidered
		,CASE
			WHEN prjcc.IsDeleted = 'N' OR
				prjcc.IsDeleted IS NULL THEN 0
			ELSE 1
		END
		,'Migrated'
		,GETDATE()
		,prjcc.[ModifiedBY]
		,prjcc.[ModifiedDateTime]
	FROM AVMDART.[MAS].[DeptCauseCode](NOLOCK) prjcc
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjcc.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) appcc
		ON appcc.ProjectID = prjapp.ProjectID
		AND appcc.CauseCode = prjcc.CauseCode
	WHERE appcc.ProjectID IS NULL

-- If there is no cause code for the project, push 'No Data Available'
INSERT INTO AVL.DEBT_MAP_CauseCode (CauseCode,
CauseStatusID,
ProjectID,
IsHealConsidered,
IsDeleted,
CreatedBy,
CreatedDate,
ModifiedBy,
ModifiedDate)
	SELECT
		'No Data Available'
		,NULL
		,prjapp.ProjectID
		,NULL
		,0
		,'Migrated'
		,GETDATE()
		,NULL
		,NULL
	FROM @ProjectDetailsITSM prjdet
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) avlcc
		ON avlcc.ProjectID = prjapp.ProjectID
	WHERE avlcc.ProjectID IS NULL


PRINT 'End of Cause Code'

---------------------------------------- RESOLUTION CODE ----------------------------------------

PRINT 'Start of Resolution Code'

INSERT INTO AVL.DEBT_MAP_ResolutionCode (ResolutionCode,
ResolutionStatusID,
ProjectID,
IsHealConsidered,
IsDeleted,
CreatedBy,
CreatedDate,
ModifiedBy,
ModifiedDate)
	SELECT DISTINCT
		deptres.ResolutionCode
		,NULL AS ResolutionSatusID
		,prjapp.ProjectID
		,deptres.IsHealConsidered
		,CASE
			WHEN deptres.IsDeleted = 'N' OR
				deptres.IsDeleted IS NULL THEN 0
			ELSE 1
		END AS IsDeleted
		,'Migrated'
		,GETDATE() AS CreatedDate
		,NULL AS ModifiedBy
		,NULL AS ModifiedDate
	FROM AVMDART.MAS.DeptResolutionCode(NOLOCK) deptres
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = deptres.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) apprc
		ON apprc.ProjectID = prjapp.ProjectID
		AND apprc.ResolutionCode = deptres.ResolutionCode
	WHERE apprc.ProjectID IS NULL

-- If there is no resolution code for the project, push 'No Data Available'
INSERT INTO AVL.DEBT_MAP_ResolutionCode (ResolutionCode,
ResolutionStatusID,
ProjectID,
IsHealConsidered,
IsDeleted,
CreatedBy,
CreatedDate,
ModifiedBy,
ModifiedDate)
	SELECT
		'No Data Available'
		,NULL
		,prjapp.ProjectID
		,NULL
		,0
		,'Migrated'
		,GETDATE()
		,NULL
		,NULL
	FROM @ProjectDetailsITSM prjdet
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) avlrc
		ON avlrc.ProjectID = prjapp.ProjectID
	WHERE avlrc.ProjectID IS NULL

PRINT 'End of Resolution Code'

---------------------------------------- TICKET SOURCE ----------------------------------------
PRINT 'Start of Ticket Source'

INSERT INTO AVL.TK_MAP_SourceMapping (SourceID,
SourceName,
ProjectID,
IsDeleted,
CreatedDateTime,
CreatedBy,
ModifiedDateTime,
ModifiedBy,
IsFixedSource,
IsDefaultSource,
Position)
	SELECT DISTINCT
		ISNULL(tksource.TicketSourceID, 8) -- By default 8 which is 'Ticketing Tool'
		,prjsource.SourceName
		,prjapp.ProjectID
		,CASE
			WHEN prjsource.IsDeleted = 'N' OR
				prjsource.IsDeleted IS NULL THEN 0
			ELSE 1
		END AS IsDeleted
		,GETDATE() AS CreateDateTime
		,'Migrated'
		,NULL AS ModifiedDateTime
		,NULL AS ModifiedBy
		,prjsource.IsFixedSource
		,prjsource.IsDefaultSource
		,prjsource.Position
	FROM AVMDART.PRJ.ProjectSourceDetails(NOLOCK) prjsource
	LEFT JOIN AVMDART.MAS.TicketSourceMaster(NOLOCK) tsource
		ON prjsource.DARTTicketSourceID = tsource.DARTTicketSourceID
	LEFT JOIN AVL.TK_MAS_TicketSource(NOLOCK) tksource
		ON tksource.TicketSourceName = tsource.DARTTicketSource
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjsource.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_SourceMapping(NOLOCK) apptsm
		ON apptsm.ProjectID = prjapp.ProjectID
		AND apptsm.SourceID = prjsource.DARTTicketSourceID
		AND apptsm.SourceName = prjsource.SourceName
	WHERE apptsm.ProjectID IS NULL

---------------------------------------- TICKET UPLOAD CONFIGURATION ----------------------------------------

INSERT INTO dbo.TicketUploadProjectConfiguration (ProjectID,
IsManualOrAuto,
SharePath,
Ismailer,
TicketSharePathUsers,
IsDeleted,
CreatedBy,
CreatedDateTime,
ModifiedBy,
ModifiedDateTime)
	SELECT DISTINCT
		prjapp.ProjectID
		,'M'
		,NULL
		,'N'
		,prjconfig.TicketSharePathUsers
		,0
		,'Migrated'
		,GETDATE()
		,NULL
		,NULL
	FROM AVMDART.MAP.ProjectConfig(NOLOCK) prjconfig
	JOIN @ProjectDetailsITSM prjdet
		ON prjdet.ProjectID = prjconfig.ProjectID
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN dbo.TicketUploadProjectConfiguration(NOLOCK) apptupc
		ON apptupc.ProjectID = prjapp.ProjectID
	WHERE apptupc.ProjectID IS NULL


INSERT INTO dbo.TicketUploadProjectConfiguration (ProjectID,
IsManualOrAuto,
SharePath,
Ismailer,
TicketSharePathUsers,
IsDeleted,
CreatedBy,
CreatedDateTime,
ModifiedBy,
ModifiedDateTime)
	SELECT
		prjapp.ProjectID
		,'M'
		,NULL
		,'N'
		,'0;0;0'
		,0
		,'Migrated'
		,GETDATE()
		,NULL
		,NULL
	FROM @ProjectDetailsITSM prjdet
	JOIN AVL.MAS_ProjectMaster(NOLOCK) prjapp
		ON prjapp.EsaProjectID = prjdet.EsaProjectID
		AND prjapp.IsDeleted = 0
	LEFT JOIN dbo.TicketUploadProjectConfiguration(NOLOCK) prjconfig
		ON prjconfig.ProjectID = prjapp.ProjectID
	WHERE prjconfig.ProjectID IS NULL

-- Insert Configuration Progress Logic for ITSM Configuration Module
DECLARE @ApplensAccountID BIGINT;

SELECT
	@ApplensAccountID = PM.CustomerID
FROM @ProjectDetailsITSM PD
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
	ON PM.EsaProjectID = PD.EsaProjectID
	AND pm.IsDeleted = 0
JOIN AVL.Customer(NOLOCK) Cust
	ON Cust.ESA_AccountID = PD.AccountID
	AND PM.CustomerID = Cust.CustomerID
	AND cust.IsDeleted = 0

EXEC SP_DataMigration_InsertConfigurationProgress @ApplensAccountID, @ESAProjectIDs, 1


-- Log the ITSM Configuration migration is successful for the respective account.
UPDATE DataMigrationLog SET ITSMStatus = 'S' WHERE AccountID = @AccountId

END TRY 

BEGIN CATCH

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()
	SELECT @ErrorMessage AS ErrorMessage

	-- Log the Error in Data Migration Log Table.   
	UPDATE DataMigrationLog SET	ITSMStatus = 'F', ITSMErrorMessage = @ErrorMessage
	WHERE AccountID = @AccountId

END CATCH

END
