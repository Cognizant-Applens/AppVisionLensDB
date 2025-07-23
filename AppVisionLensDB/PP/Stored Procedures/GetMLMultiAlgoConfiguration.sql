/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE PP.GetMLMultiAlgoConfiguration  --10337  
(@ProjectID BIGINT)    
AS BEGIN    
Select     
PAV.AttributeValueID AS AlgorithmId,    
PAV.AttributeValueName AS AlgorithmName,    
ML.Preference,    
ISNULL((CASE WHEN ML.Isdeleted = 0 THEN 1 ELSE 0 END),0) AS IsSelected,    
--0 as IsMLConfigured  
CASE WHEN PDD.ProjectID IS NULL THEN 0 ELSE 1 END AS IsMLConfigured    
FROM MAS.PPAttributeValues PAV    
INNER JOIN MAS.PPAttributes PA ON PA.AttributeID = PAV.AttributeID AND PA.AttributeName ='Algorithms'    
LEFT JOIN PP.MLMultiAlgoConfiguration ML ON ML.AlgorithmId=PAV.AttributeValueID AND ML.ProjectID=@ProjectID    
LEFT JOIN AVL.MAS_ProjectDebtDetails PDD ON PDD.ProjectID = @ProjectID AND PDD.Isdeleted=0 AND (PDD.IsAutoClassified ='Y' OR PDD.IsAutoClassifiedInfra='Y')    
END
