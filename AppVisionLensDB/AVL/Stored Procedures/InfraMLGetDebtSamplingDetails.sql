/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[InfraMLGetDebtSamplingDetails] 10337
CREATE PROCEDURE [AVL].[InfraMLGetDebtSamplingDetails]
 @ProjectID bigint

 AS 
 BEGIN
 BEGIN TRY

          
	      DECLARE @StartDate DATETIME,@EndDate DATETIME

          DECLARE @CountForTicketValidates INT
 
          DECLARE @CountForOptNull INT
 
          DECLARE @CountForTicketSampling INT
 
          DECLARE @CountForResNull INT
 
          DECLARE @OptionalFieldID INT;
 
          DECLARE @PresenceOfOptional BIT;
 
          DECLARE @IsRegenerated BIT, 
                  @INIID         BIGINT;



--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled=(SELECT TOP 1 ISNULL(IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster WHERE ProjectID=@ProjectID AND IsDeleted=0)

--Optional field id  
SET @OptionalFieldID=(SELECT TOP 1 OptionalFieldID FROM [AVL].[ML_MAP_OptionalProjMappingInfra] WHERE 
ProjectID=@ProjectID AND IsDeleted=0 ORDER BY Id)

--Regenerated transaction id or not  
SET @IsRegenerated=(SELECT TOP 1 ISNULL([IsRegenerated],0) FROM [AVL].[ML_PRJ_InitialLearningStateInfra] WHERE 
[ProjectID]=@ProjectID AND [IsDeleted]=0 ORDER BY ID)

--latest initial learning transaction id  
SET @INIID = (SELECT TOP 1 ID FROM [AVL].[ML_PRJ_InitialLearningStateInfra]
	WHERE [ProjectID] = @ProjectID	AND [IsDeleted] = 0	ORDER BY ID DESC)

--count for valid ticket from ticketvalidation  for specific project  
SET @CountForTicketValidates = (SELECT
		COUNT([TicketID])
	FROM [AVL].[ML_TRN_TicketValidationInfra]
	WHERE  [ProjectID]= @ProjectID
	AND [IsDeleted] = 0)

--count of tickets in ticketvalidation table with optional field='' or optional field is empty  
SET @countforoptnull = (SELECT
		COUNT(ticketid)
	FROM AVL.ML_TRN_TicketValidationInfra
	WHERE projectid = @ProjectID
	AND isdeleted = 0
	AND (optionalfieldproj = ''
	OR optionalfieldproj IS NULL))

--count for valid ticket from TicketsAfterSampling  for specific project  
SET @CountForTicketSampling = (SELECT
		COUNT([TicketID])
	FROM [AVL].[ML_TRN_TicketsAfterSamplingInfra]
	WHERE [ProjectID] = @ProjectID
	AND [IsDeleted] = 0)
--count for valid ticket from TicketsAfterSampling where Res_Base_WorkPattern is empty or null  for specific project
SET @CountForResNull = (SELECT
		COUNT([TicketID])
	FROM [AVL].[ML_TRN_TicketsAfterSamplingInfra]
	WHERE [ProjectID] = @ProjectID
	AND [IsDeleted] = 0
	AND ([Desc_Base_WorkPattern] = ''
	OR [Desc_Base_WorkPattern] IS NULL))

SELECT TOP 1 @StartDate=StartDate,@EndDate=EndDate FROM [AVL].[ML_PRJ_InitialLearningStateInfra] WHERE ProjectID=@ProjectID AND IsDeleted=0 ORDER BY ID DESC

SELECT
	 TicketID
	,TowerID
	,DebtClassificationMapID
	,ResidualDebtMapID
	,AvoidableFlag
	,CauseCodeMapID
	,ResolutionCodeMapID INTO #TmpTicketDetails
FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK)
WHERE ProjectID = @ProjectID
AND IsDeleted = 0
AND DARTStatusID = 8
and Closeddate BETWEEN @StartDate AND @EndDate


IF ((@CountForTicketValidates = @CountForOptNull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4
OR (@CountForTicketSampling = @CountForResNull
AND @OptionalFieldID <> 4)) BEGIN
SET @PresenceOfOptional = 0

--if both counts are equal even if optional field is defined or optional field is not defined  
PRINT '0'

SELECT
	 TD.TicketID
	,DTV.TicketDescription
	,TD.TowerID
	,AD.TowerName
	,DTV.ProjectID
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
INNER JOIN AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) DTV
	ON DTV.ticketid = TD.ticketid
	AND DTV.projectid = @ProjectID
	AND DTV.isdeleted = 0
	AND DTV.TowerID = TD.TowerID

JOIN AVL.ML_MAP_OptionalProjMappingInfra OPM
	ON DTV.ProjectID = OPM.ProjectId
	AND OPM.IsDeleted = 0
	AND OPM.ProjectId = @ProjectID

LEFT JOIN AVL.DEBT_MAS_DebtClassificationInfra ATTRFM
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

LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AD
	ON AD.InfraTowerTransactionID = DTV.TowerID
	AND AD.IsDeleted = 0

LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG
	ON REG.initiallearningid = @INIID
	AND DTV.TowerID = REG.TowerID
	AND REG.ProjectID = @ProjectID

WHERE DTV.ProjectID = @ProjectID
AND DTV.IsDeleted = 0

AND DTV.Desc_Base_WorkPattern <> '0'
AND ((@IsRegenerated = 1
AND REG.ID IS NOT NULL)
OR (@IsRegenerated = 0))
END



ELSE BEGIN
SET @PresenceOfOptional = 1

--optional field pattern will be sent  
SELECT
	TD.TicketID
	,DTV.TicketDescription
	,TV.OptionalFieldProj AS AdditionalText
	,TD.TowerID
	,AD.TowerName
	,DTV.ProjectID
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
INNER JOIN AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) DTV
	ON DTV.ticketid = TD.ticketid

	AND DTV.projectid = @ProjectID
	AND DTV.isdeleted = 0

	AND DTV.TowerID = TD.TowerID
JOIN AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
	ON DTV.ticketid = TV.ticketid
	AND TV.isdeleted = 0
	AND DTV.isdeleted = 0
	AND TV.projectid = @ProjectID
	AND DTV.projectid = @ProjectID
JOIN AVL.ML_MAP_OptionalProjMappingInfra OPM
	ON DTV.projectid = OPM.projectid
	AND OPM.IsDeleted = 0
	AND OPM.projectid = @ProjectID
LEFT JOIN AVL.DEBT_MAS_DebtClassificationInfra ATTRFM
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
LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AD
	ON AD.InfraTowerTransactionID = DTV.TowerID
	AND AD.IsDeleted = 0
LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG
	ON REG.initiallearningid = @INIID
	AND DTV.TowerID= REG.TowerID
	AND REG.ProjectID = @ProjectID
WHERE DTV.ProjectID = @ProjectID
AND DTV.IsDeleted = 0
AND DTV.Desc_Base_WorkPattern <> '0'
AND ((@IsRegenerated = 1
AND REG.ID IS NOT NULL)
OR (@IsRegenerated = 0))
END


END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT @ErrorMessage=ERROR_MESSAGE()

EXEC AVL_InsertError 'AVL.InfraMLGetDebtSamplingDetails',@ErrorMessage,@ProjectID,0

END CATCH
END
