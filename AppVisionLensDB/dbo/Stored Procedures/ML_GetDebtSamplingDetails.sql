/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================  
-- Author:           Devika  
-- Create date:      11 FEB 2018  
-- Description:      SP for Initial Learning  

-- MODIFICATION HISTORY 
-- USERID    NAME     DATE             REASON 
-- 687591    MENAKA   20-2-2019        Formatted the procedure 
-- 687591    MENAKA   20-2-2019        changed the fetching of sampling details from TicketDetail table instead of TicketsAfterSampling
-- 687591    MENAKA   29-5-2019        Included MultiLingual code
-- ============================================================================  
CREATE PROCEDURE [dbo].[ML_GetDebtSamplingDetails]  
  @ProjectID INT 
AS 
  BEGIN
 
      BEGIN TRY 

          DECLARE @CountForTicketValidates INT
 
          DECLARE @countforoptnull INT
 
          DECLARE @CountForTicketSampling INT
 
          DECLARE @countforresnull INT
 
          DECLARE @OptionalFieldID INT;
 
          DECLARE @PresenceOfOptional BIT;
 
          DECLARE @IsRegenerated BIT, 
                  @INIID         BIGINT;

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)




--------------------------------------------------------------

--Optional field id  
SET @OptionalFieldID = (SELECT TOP 1
		optionalfieldid
	FROM AVL.ML_MAP_OPTIONALPROJMAPPING
	WHERE projectid = @ProjectID
	AND isactive = 1)
--Regenerated transaction id or not  
SET @IsRegenerated = (SELECT TOP 1
		ISNULL(isregenerated, 0)
	FROM AVL.ML_PRJ_INITIALLEARNINGSTATE
	WHERE projectid = @ProjectID
	AND isdeleted = 0
	ORDER BY id DESC)
--latest initial learning transaction id  
SET @INIID = (SELECT TOP 1
		id
	FROM AVL.ML_PRJ_INITIALLEARNINGSTATE
	WHERE projectid = @ProjectID
	AND isdeleted = 0
	ORDER BY id DESC)
--count for valid ticket from ticketvalidation  for specific project  
SET @CountForTicketValidates = (SELECT
		COUNT(ticketid)
	FROM AVL.ML_TRN_TICKETVALIDATION
	WHERE projectid = @ProjectID
	AND isdeleted = 0)
--count of tickets in ticketvalidation table with optional field='' or optional field is empty  
SET @countforoptnull = (SELECT
		COUNT(ticketid)
	FROM AVL.ML_TRN_TICKETVALIDATION
	WHERE projectid = @ProjectID
	AND isdeleted = 0
	AND (optionalfieldproj = ''
	OR optionalfieldproj IS NULL))
--count for valid ticket from TicketsAfterSampling  for specific project  
SET @CountForTicketSampling = (SELECT
		COUNT(ticketid)
	FROM AVL.ML_TRN_TICKETSAFTERSAMPLING
	WHERE projectid = @ProjectID
	AND isdeleted = 0)
--count for valid ticket from TicketsAfterSampling where Res_Base_WorkPattern is empty or null  for specific project
SET @countforresnull = (SELECT
		COUNT(ticketid)
	FROM AVL.ML_TRN_TICKETSAFTERSAMPLING
	WHERE projectid = @ProjectID
	AND isdeleted = 0
	AND (res_base_workpattern = ''
	OR res_base_workpattern IS NULL))

	DECLARE @StartDate DATETIME,@EndDate DATETIME
	SELECT TOP 1 @StartDate=StartDate,@EndDate=EndDate FROM AVL.ML_PRJ_InitialLearningState WHERE ProjectID=@ProjectID AND IsDeleted=0 ORDER BY ID DESC

SELECT
	TicketID
	,ApplicationID
	,DebtClassificationMapID
	,ResidualDebtMapID
	,AvoidableFlag
	,CauseCodeMapID
	,ResolutionCodeMapID INTO #TmpTicketDetails
FROM AVL.TK_TRN_TicketDetail(NOLOCK)
WHERE ProjectID = @ProjectID
AND IsDeleted = 0
AND DARTStatusID = 8
and Closeddate BETWEEN @StartDate AND @EndDate

IF ((@CountForTicketValidates = @countforoptnull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4
OR (@CountForTicketSampling = @countforresnull
AND @OptionalFieldID <> 4)) BEGIN
SET @PresenceOfOptional = 0

--if both counts are equal even if optional field is defined or optional field is not defined  
PRINT '0'

SELECT
	TD.ticketid
	,DTV.ticketdescription
	,TD.applicationid
	,AD.applicationname
	,DTV.projectid
	,TD.debtclassificationmapid AS 'DebtClassificationID'
	,ATTRFM.debtclassificationname AS DebtClassificationName
	,TD.avoidableflag AS 'AvoidableFlagID'
	,ATTRFM1.avoidableflagname AS AvoidableFlagName
	,TD.residualdebtmapid AS 'ResidualDebtID'
	,ATTRFM2.[residualdebtname] AS ResidualDebt
	,TD.causecodemapid AS 'CauseCodeID'
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DeptCC.MCauseCode,'') != '' THEN DeptCC.MCauseCode ELSE DeptCC.CauseCode END AS [CauseCode] 
	,TD.resolutioncodemapid AS 'ResolutionCodeID'
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != '' THEN DRC.MResolutionCode ELSE DRC.ResolutionCode END AS [ResolutionCode] 
	,
	
	CASE
		WHEN DTV.desc_base_workpattern = '0' THEN ''
		ELSE DTV.desc_base_workpattern
	END AS TicketDescriptionPattern
	,CASE
		WHEN DTV.desc_sub_workpattern = '0' THEN ''
		ELSE DTV.desc_sub_workpattern
	END AS TicketDescriptionSubPattern
	,@PresenceOfOptional AS PresenceOfOptioanl
FROM #TmpTicketDetails TD
INNER JOIN AVL.ML_TRN_TICKETSAFTERSAMPLING(NOLOCK) DTV
	ON DTV.ticketid = TD.ticketid

	AND DTV.projectid = @ProjectID
	AND DTV.isdeleted = 0

	AND DTV.applicationid = TD.applicationid
JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OPM
	ON DTV.projectid = OPM.projectid
	AND OPM.isactive = 1
	AND OPM.projectid = @ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] ATTRFM
	ON ATTRFM.debtclassificationid = TD.DebtClassificationMapID
LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG ATTRFM1
	ON ATTRFM1.avoidableflagid = TD.AvoidableFlag
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] ATTRFM2
	ON ATTRFM2.residualdebtid = TD.ResidualDebtMapID
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE](NOLOCK) DeptCC
	ON TD.CauseCodeMapID = DeptCC.causeid
	AND DeptCC.projectid = @ProjectID
	AND DeptCC.isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](NOLOCK) DRC
	ON DRC.resolutionid = TD.ResolutionCodeMapID
	AND DRC.projectid = @ProjectID
	AND DRC.isdeleted = 0
LEFT JOIN AVL.APP_MAS_APPLICATIONDETAILS(NOLOCK) AD
	ON AD.applicationid = DTV.applicationid
	AND AD.isactive = 1
LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS(NOLOCK) REG
	ON REG.initiallearningid = @INIID
	AND DTV.applicationid = REG.applicationid
	AND REG.projectid = @ProjectID
WHERE DTV.projectid = @ProjectID
AND DTV.isdeleted = 0

AND DTV.desc_base_workpattern <> '0'
AND ((@IsRegenerated = 1
AND REG.id IS NOT NULL)
OR (@IsRegenerated = 0))
END ELSE BEGIN
SET @PresenceOfOptional = 1

--optional field pattern will be sent  
SELECT
	TD.ticketid
	,DTV.ticketdescription
	,TV.OptionalFieldProj AS AdditionalText
	,TD.applicationid
	,AD.applicationname
	,DTV.projectid
	,TD.debtclassificationmapid AS debtclassificationid
	,ATTRFM.debtclassificationname AS DebtClassificationName
	,TD.avoidableflag AS avoidableflagid
	,ATTRFM1.avoidableflagname AS AvoidableFlagName
	,TD.residualdebtmapid AS residualdebtid
	,ATTRFM2.[residualdebtname] AS ResidualDebt
	,TD.causecodemapid AS causecodeid
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DeptCC.MCauseCode,'') != '' THEN DeptCC.MCauseCode ELSE DeptCC.CauseCode END AS [CauseCode]
	,TD.resolutioncodemapid AS resolutioncodeid
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != '' THEN DRC.MResolutionCode ELSE DRC.ResolutionCode END AS [ResolutionCode] 
	,
	
	CASE
		WHEN DTV.desc_base_workpattern = '0' THEN ''
		ELSE DTV.desc_base_workpattern
	END AS TicketDescriptionPattern
	,CASE
		WHEN DTV.desc_sub_workpattern = '0' THEN ''
		ELSE DTV.desc_sub_workpattern
	END AS TicketDescriptionSubPattern
	,CASE
		WHEN DTV.res_base_workpattern = '0' THEN ''
		ELSE DTV.res_base_workpattern
	END AS Res_Base_WorkPattern
	,CASE
		WHEN DTV.res_sub_workpattern = '0' THEN ''
		ELSE DTV.res_sub_workpattern
	END AS Res_Sub_WorkPattern
	,OPM.optionalfieldid
	,@PresenceOfOptional AS PresenceOfOptioanl

FROM #TmpTicketDetails TD
INNER JOIN AVL.ML_TRN_TICKETSAFTERSAMPLING(NOLOCK) DTV
	ON DTV.ticketid = TD.ticketid

	AND DTV.projectid = @ProjectID
	AND DTV.isdeleted = 0

	AND DTV.applicationid = TD.applicationid
JOIN AVL.ML_TRN_TICKETVALIDATION TV
	ON DTV.ticketid = TV.ticketid
	AND TV.isdeleted = 0
	AND DTV.isdeleted = 0
	AND TV.projectid = @ProjectID
	AND DTV.projectid = @ProjectID
JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OPM
	ON DTV.projectid = OPM.projectid
	AND OPM.isactive = 1
	AND OPM.projectid = @ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] ATTRFM
	ON ATTRFM.debtclassificationid = TD.DebtClassificationMapID
LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG ATTRFM1
	ON ATTRFM1.avoidableflagid = TD.AvoidableFlag
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] ATTRFM2
	ON ATTRFM2.residualdebtid = TD.ResidualDebtMapID
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE](NOLOCK) DeptCC
	ON TD.CauseCodeMapID = DeptCC.causeid
	AND DeptCC.projectid = @ProjectID
	AND DeptCC.isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](NOLOCK) DRC
	ON DRC.resolutionid = TD.ResolutionCodeMapID
	AND DRC.projectid = @ProjectID
	AND DRC.isdeleted = 0
LEFT JOIN AVL.APP_MAS_APPLICATIONDETAILS(NOLOCK) AD
	ON AD.applicationid = DTV.applicationid
	AND AD.isactive = 1
LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS(NOLOCK) REG
	ON REG.initiallearningid = @INIID
	AND DTV.applicationid = REG.applicationid
	AND REG.projectid = @ProjectID
WHERE DTV.projectid = @ProjectID
AND DTV.isdeleted = 0
AND DTV.desc_base_workpattern <> '0'
AND ((@IsRegenerated = 1
AND REG.id IS NOT NULL)
OR (@IsRegenerated = 0))
END
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

--INSERT Error      
EXEC AVL_INSERTERROR	'[dbo].[ML_GetDebtSamplingDetails]  '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END
