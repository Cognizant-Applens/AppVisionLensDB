/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetProjectDataDictionary]
AS
SET NOCOUNT ON

INSERT INTO AVL.ProjectDataDictionary(
      [ProjectID]
      ,[CauseCodeID]
      ,[ResolutionCodeID]
      ,[DebtClassificationID]
      ,[AvoidableFlagID])
SELECT
Prjdd.ProjectID,Prjdd.CauseCodeID,
Prjdd.ResolutionCodeID,
Prjdd.DebtClassificationID,
Prjdd.AvoidableFlagID from
(SELECT PDD.ProjectID,PDD.CauseCodeID,
PDD.ResolutionCodeID,
PDD.DebtClassificationID,
PDD.AvoidableFlagID
FROM avl.Debt_MAS_ProjectDataDictionary PDD With (NOLOCK)
WHERE PDD.IsDeleted=0
GROUP BY PDD.ProjectID,PDD.CauseCodeID,
PDD.ResolutionCodeID,
PDD.DebtClassificationID,
PDD.AvoidableFlagID) prjdd
left join AVL.ProjectDataDictionary Mas (NOLOCK)
    on mas.[ProjectID]   = prjdd.[ProjectID]
    and mas.[CauseCodeID] = prjdd.[CauseCodeID]
    and Mas.[ResolutionCodeID] = prjdd.[ResolutionCodeID]
    and Mas.[DebtClassificationID] = prjdd.[DebtClassificationID]
    and Mas.[AvoidableFlagID] = prjdd.[AvoidableFlagID]
where mas.[ProjectID] IS NULL or 
    mas.[CauseCodeID] is null or
       mas.[ResolutionCodeID] is null or
    mas.[DebtClassificationID] is null or
    mas.[AvoidableFlagID] is null
