/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [ADM].[ALM_GetEpicAccessByExecutionMethod]
(
@projectId BIGINT
)
AS            
BEGIN     
BEGIN TRY  
SET NOCOUNT ON;  


SELECT * INTO #tempProjectLevelExecutionMethod FROM (
SELECT Distinct AttributeValueID AS ExecutionMethod
FROM PP.ProjectAttributeValues(NOLOCK)
WHERE projectid= @projectId AND AttributeID=3  AND IsDeleted=0
)t1 


SELECT TOP 1 ProjectId  
FROM  [PP].[ALM_MAP_GenericWorkItemConfig](NOLOCK)
WHERE ProjectId = @projectId  AND ExecutionId IN(SELECT ExecutionMethod FROM #tempProjectLevelExecutionMethod(NOLOCK))
AND WorkItemTypeId = 1 AND IsDeleted =0
SET NOCOUNT OFF;
END TRY 
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[ALM_GetEpicAccessByExecutionMethod] ', @ErrorMessage, 0,@projectId
		RETURN @ErrorMessage
  END CATCH             
END
