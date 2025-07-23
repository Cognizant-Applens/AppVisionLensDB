/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [ML].[VW_TicketDetailsForMachineLearning]
AS
	SELECT DISTINCT	
				CP.ID AS InitialLearningID
			,TV.ProjectID
			,TV.TicketID
			,TV.DescriptionText
			,CASE WHEN PM.IsMultilingualEnabled = 1 AND MCP.ColumnID =1 AND 
				MLT.IsTicketDescriptionUpdated = 0 AND ISNULL(MLT.TicketDescription,'')!='' THEN 
				MLT.TicketDescription 									
			ELSE TV.TicketDescription END AS TicketDescription
			,ISNULL(TV.ApplicationID,0) AS ApplicationID
			,AD.ApplicationName
			,ISNULL(TV.DebtClassificationID,0) AS DebtClassificationID
			,DC.DebtClassificationName
			,ISNULL(TV.AvoidableFlagID,0) AS AvoidableFlagID
			,AF.AvoidableFlagName
			,ISNULL(TV.ResidualDebtID,0) AS ResidualDebtID
			,RD.ResidualDebtName
			,ISNULL(TV.CauseCodeID,0) AS CauseCodeID
			,CASE WHEN PM.IsMultilingualEnabled = 1 AND MCP.ColumnID =5 AND ISNULL(CCM.MCauseCode,'') != '' THEN CCM.MCauseCode ELSE CCM.CauseCode END AS [CauseCodeName] 
			,ISNULL(TV.ResolutionCodeID,0)	 AS ResolutionCodeID		
			,CASE WHEN PM.IsMultilingualEnabled = 1 AND MCP.ColumnID =6 AND ISNULL(RCM.MResolutionCode,'') != '' THEN RCM.MResolutionCode ELSE RCM.ResolutionCode END AS [ResolutionCodeName]
			,OD.ApplicationTypeID
			,OD.ApplicationTypename
			,PT.PrimaryTechnologyID
			,PT.PrimaryTechnologyName
			,CASE WHEN CP.IsOptionalField = 1 AND PM.IsMultilingualEnabled = 1 AND MCP.ColumnID =3 AND 
				MLT.IsResolutionRemarksUpdated = 0 AND ISNULL(MLT.ResolutionRemarks,'')!='' THEN 
				MLT.ResolutionRemarks 
				WHEN CP.IsOptionalField = 1 THEN TV.OptionalField 					
			ELSE '' END AS OptionalField	
			,TV.TicketDescriptionBasePattern AS Desc_Base_WorkPattern
			,TV.TicketDescriptionSubPattern AS Desc_Sub_WorkPattern
			,CASE WHEN CP.IsOptionalField = 1 THEN TV.ResolutionRemarksBasePattern ELSE '0' END AS Res_Base_WorkPattern
			,CASE WHEN CP.IsOptionalField = 1 THEN TV.ResolutionRemarksSubPattern ELSE '0' END AS Res_Sub_WorkPattern 
		FROM ML.ConfigurationProgress CP
		INNER JOIN ML.TicketValidation TV ON CP.ProjectID = TV.ProjectID AND CP.ID = TV.InitialLearningID AND CP.IsDeleted = 0
		INNER JOIN AVL.MAS_ProjectMaster PM
			ON PM.ProjectID = TV.ProjectID 
			AND PM.IsDeleted=0
		JOIN AVL.TK_TRN_TicketDetail TD 
			ON TD.TicketID = TV.TicketID AND
			TD.ProjectID = TV.ProjectID
		LEFT JOIN [AVL].TK_TRN_Multilingual_TranslatedTicketDetails MLT 
			ON MLT.TimeTickerID= TD.TimeTickerID 
		LEFT JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK)
			ON MCP.ProjectID =TV.PROJECTID 
		LEFT JOIN AVL.MAS_MultilingualColumnMaster MCM WITH(NOLOCK)
			ON  MCM.ColumnID=MCP.ColumnID AND
			MCM.IsActive=1 AND MCP.IsActive = 1  
		LEFT JOIN [AVL].[APP_MAP_ApplicationProjectMapping] AMP
			ON TV.Applicationid = AMP.Applicationid
			AND TV.ProjectID = AMP.ProjectID		
		LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AD
			ON AMP.ApplicationID = AD.ApplicationID	
		LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] DC
			ON TV.DebtClassificationId = DC.DebtClassificationID
		LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG AF
			ON TV.AvoidableFlagID = AF.AvoidableFlagID
		LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] RD
			ON TV.ResidualDebtID = RD.ResidualDebtID
		LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] CCM
			ON TV.CauseCodeID = CCM.CAUSEID
			AND TV.ProjectID = CCM.ProjectID
			AND CCM.IsDeleted = 0
		LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] RCM
			ON TV.ResolutionCodeID = RCM.RESOLUTIONID
			AND TV.ProjectID = RCM.ProjectID
			AND RCM.IsDeleted = 0
		LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] OD
			ON AD.CodeOwnership = OD.ApplicationTypeID
		LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] PT
			ON AD.PrimaryTechnologyID = PT.PrimaryTechnologyID
		WHERE TV.IsDeleted = 0
