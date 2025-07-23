/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [ADM].[ALM_GetParentWorkItemByExecutionMethod]
(
@userId VARCHAR(50),
@projectId BIGINT,
@applicationId BIGINT,
@workItemTypeId  BIGINT
)
AS            
BEGIN     
BEGIN TRY       
SET NOCOUNT ON;  

DECLARE @executionId BIGINT
DECLARE @parentHierarchyId BIGINT
DECLARE @workTypeMapId BIGINT
DECLARE @isParentMandate BIT

SELECT @executionId=ExecutionMethod 
FROM [ADM].[ALMApplicationDetails](NOLOCK) WHERE  ApplicationID=@applicationId


SELECT * INTO #tempProjectLevelWorkItemTypeId FROM (
SELECT ParentHierarchyId,IsParentMandate,WorkItemTypeId
FROM [PP].[ALM_MAP_GenericWorkItemConfig](NOLOCK) 
WHERE projectid= @projectId AND ExecutionId=@executionId 
AND WorkItemTypeId=@workItemTypeId AND IsDeleted=0
)t1 

SELECT @parentHierarchyId= ParentHierarchyId
FROM #tempProjectLevelWorkItemTypeId (NOLOCK)


SELECT @parentHierarchyId= WorkTypeMapId FROM PP.ALM_MAP_WorkType(NOLOCK)
WHERE worktypeid=@parentHierarchyId AND isdefault='Y'

SELECT * INTO #tempWorkItemDetails FROM (
SELECT WorkItemDetailsId,WorkItem_Id,WorkItem_Title,SprintDetailsId,ServiceId --added sprint id for filtering based on sprint
FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) 
WHERE Project_Id=@projectId AND WorkTypeMapId=@parentHierarchyId 
AND StatusMapId NOT IN(4,5) 
AND IsDeleted=0
)t3


SELECT @isParentMandate=IsParentMandate FROM #tempProjectLevelWorkItemTypeId(NOLOCK)


SELECT 
TWI.WorkItem_Id AS ParentWorkItemId,
TWI.WorkItem_Title AS ParentWorkItemTitle,
@isParentMandate AS 'IsParentMandate',TWI.SprintDetailsId AS SprintDetailsId, --added sprint id for filtering based on sprint
TWI.ServiceId
FROM #tempWorkItemDetails(NOLOCK) AS TWI
INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) AS WAP
ON TWI.WorkItemDetailsId=WAP.WorkItemDetailsId
WHERE Application_Id=@applicationId AND IsDeleted=0


SET NOCOUNT OFF;
END TRY 
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[ALM_GetParentWorkItemByExecutionMethod] ', @ErrorMessage, @userId,@projectId
		RETURN @ErrorMessage
  END CATCH             
END
