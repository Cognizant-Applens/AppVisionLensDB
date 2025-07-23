/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [ML].[VW_SamplingTicketsForRuleExtraction]
AS
	SELECT
		DISTINCT
		PM.ProjectID
		,TV.InitialLearningId
		,TV.TicketID
		,ISNULL(TV.ApplicationID,0) AS ApplicationID
		,AMR.ApplicationName
		,TV.ApplicationType
		,AT.ApplicationTypename
		,TV.TechnologyID
		,MT.Primarytechnologyname AS TechnologyName
		,ISNULL(TD.CauseCodeMapID,0) AS  CauseCodeID
		,CASE WHEN PM.IsMultilingualEnabled = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,5,1)) = 1) AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
		,ISNULL(TD.ResolutionCodeMapID,0) AS ResolutionCodeID
		,CASE WHEN PM.IsMultilingualEnabled = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,6,1)) = 1) AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] 		
		,ISNULL(TD.DebtClassificationMapID,0) AS DebtClassificationID
		,AM.Debtclassificationname AS DebtClassification
		,ISNULL(TD.AvoidableFlag,0) AS AvoidableFlagID
		,AM1.Avoidableflagname AS AvoidableFlag
		,ISNULL(TD.ResidualDebtMapID,0) AS ResidualDebtID
		,AM2.Residualdebtname AS ResidualDebt
		,TV.Desc_Base_WorkPattern
		,TV.Desc_Sub_WorkPattern
		,TV.Res_Base_WorkPattern
		,TV.Res_Sub_WorkPattern
		,TV.DebtClassifiedBy
	FROM ML.TRN_TicketsAfterSampling(NOLOCK) TV
	JOIN avl.TK_TRN_TicketDetail TD
		ON TV.Projectid = TD.ProjectID
		--AND TV.Initiallearningid = @LatestID
		AND TD.Ticketid = TV.Ticketid		
		AND TV.Isdeleted = 0 AND TD.IsDeleted = 0
	LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
		ON TD.Debtclassificationmapid = AM.Debtclassificationid
	LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
		ON TD.Avoidableflag = AM1.Avoidableflagid
	LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
		ON TD.Residualdebtmapid = AM2.Residualdebtid
	LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
		ON TD.Causecodemapid = AM3.Causeid		
		AND TV.Projectid = AM3.Projectid
		AND AM3.Isdeleted = 0
	LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
		ON TD.Resolutioncodemapid = AM4.Resolutionid		
		AND TV.Projectid = AM4.Projectid
		AND AM4.Isdeleted = 0
	LEFT JOIN [AVL].[APP_MAP_ApplicationProjectMapping] AMP
		ON TV.Applicationid = AMP.Applicationid
		AND TV.ProjectID = AMP.ProjectID
	LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
		ON AMP.Applicationid = AMR.Applicationid
	LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
		ON AMR.Codeownership = AT.Applicationtypeid
	LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
		ON AMR.Primarytechnologyid = MT.Primarytechnologyid
	LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
		ON TV.Projectid = PM.Projectid
		WHERE TV.Desc_base_workpattern <> '0'
