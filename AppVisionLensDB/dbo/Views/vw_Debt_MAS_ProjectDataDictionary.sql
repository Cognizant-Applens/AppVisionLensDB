/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE View [dbo].[vw_Debt_MAS_ProjectDataDictionary] AS

				SELECT
				DD.[ProjectID],
				PM.ProjectName,
				DD.[ApplicationID],
				AD.ApplicationName,
				DD.[CauseCodeID],
				CC.CauseCode,
				DD.[ResolutionCodeID],
				RC.ResolutionCode,
				DD.[DebtClassificationID],
				DC.DebtClassificationName,
				DD.[AvoidableFlagID],
				AF.AvoidableFlagName,
				DD.[ResidualDebtID],
				RD.ResidualDebtName,
				DD.[ReasonForResidual],
				RFR.ReasonResidualName,
				DD.ExpectedCompletionDate,
				DD.[IsDeleted]
			FROM [AVL].[Debt_MAS_ProjectDataDictionary] (NOLOCK) DD
			JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
				ON PM.ProjectID = DD.ProjectID
			LEFT JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AD 
				ON AD.ApplicationID = DD.ApplicationID
			LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC 
				ON RC.ResolutionID = DD.ResolutionCodeID
			LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC 
				ON CC.CauseID = DD.CauseCodeID
			LEFT JOIN AVl.DEBT_MAS_DebtClassification (NOLOCK) DC 
				ON DC.DebtClassificationID = DD.DebtClassificationID
			LEFT JOIN AVL.DEBT_MAS_AvoidableFlag (NOLOCK) AF 
				ON AF.AvoidableFlagID = DD.AvoidableFlagID
			LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD 
				ON RD.ResidualDebtID = DD.ResidualDebtID
			LEFT JOIN AVL.TK_MAS_ReasonForResidual (NOLOCK) RFR 
				ON RFR.ReasonResidualID = DD.ReasonForResidual 
			WHERE ISNULL(DD.IsDeleted,0)=0
