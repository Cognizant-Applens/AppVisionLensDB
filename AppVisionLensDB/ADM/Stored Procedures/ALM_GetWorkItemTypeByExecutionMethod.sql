/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [ADM].[ALM_GetWorkItemTypeByExecutionMethod]
(
@userId VARCHAR(50),
@projectId BIGINT,
@applicationId BIGINT
)
AS            
BEGIN     
BEGIN TRY       
SET NOCOUNT ON;  



DECLARE @executionId BIGINT

SELECT @executionId=ExecutionMethod 
FROM [ADM].[ALMApplicationDetails](NOLOCK) WHERE  ApplicationID=@applicationId

SELECT  @executionId=AttributeValueID  FROM PP.ProjectAttributeValues(NOLOCK)
WHERE ProjectID=@projectId  AND AttributeValueID=@executionId AND AttributeID=3 AND IsDeleted=0

SELECT * INTO #tempProjectLevelWorkItemTypeId FROM (
SELECT Distinct WorkItemTypeId
FROM [PP].[ALM_MAP_GenericWorkItemConfig](NOLOCK) 
WHERE projectid= @projectId AND ExecutionId=@executionId 
AND WorkItemTypeId <> 1 AND IsDeleted=0
)t1 

SELECT GWT.WorkTypeId AS WorkTypeMapId, 
GWT.WorkTypeId AS WorkTypeId,
WorkTypeOrder,  
GWT.WorkTypeName AS WorkTypeName
FROM #tempProjectLevelWorkItemTypeId  (NOLOCK) AS PLWT
INNER JOIN PP.ALM_MAS_WorkType(NOLOCK) AS GWT
ON PLWT.WorkItemTypeId=GWT.WorkTypeId
WHERE  IsDeleted=0
ORDER BY WorkTypeOrder ASC

SET NOCOUNT OFF;
END TRY 
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[ALM_GetWorkItemTypeByExecutionMethod] ', @ErrorMessage, @userId,@projectId
		RETURN @ErrorMessage
  END CATCH             
END
