/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[ALM_GetSubItemWorkItemTypeByExecutionMethod] 
(
@userId VARCHAR(50),
@projectId BIGINT,
@applicationId BIGINT,
@parentWorkItemTypeId BIGINT
)
AS            
BEGIN     
BEGIN TRY       
SET NOCOUNT ON  

 

DECLARE @executionId BIGINT
DECLARE @activeExecutionId BIGINT
DECLARE @activeApplicationId BIGINT

 

SELECT @executionId=ExecutionMethod 
FROM [ADM].[ALMApplicationDetails] WITH(NOLOCK) WHERE  ApplicationID=@applicationId  AND IsDeleted=0
  
SELECT  @activeExecutionId=AttributeValueID  FROM PP.ProjectAttributeValues WITH(NOLOCK)
WHERE ProjectID=@projectId  AND AttributeValueID=@executionId AND AttributeID=3 AND IsDeleted=0

 

SELECT *  INTO #tempValidApplications FROM (
SELECT @applicationId AS ApplicationID
)T

 
SELECT @activeApplicationId=AMAS.ApplicationId
FROM #tempValidApplications AS TVP
INNER JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AS AMAS
ON TVP.ApplicationID=AMAS.ApplicationId
INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) AS APM
ON TVP.ApplicationID=APM.ApplicationId
INNER JOIN ADM.AppApplicationScope(NOLOCK) AS ASP
ON TVP.ApplicationID=ASP.ApplicationID
WHERE APM.ProjectID=@projectId AND ASP.ApplicationScopeId=1 AND ASP.IsDeleted=0
AND APM.IsDeleted=0 AND AMAS.IsActive=1

 

IF (@activeApplicationId >0)
BEGIN
SELECT WorkItemTypeId INTO #tempProjectLevelWorkItemTypeId FROM (
SELECT Distinct WorkItemTypeId
FROM [PP].[ALM_MAP_GenericWorkItemConfig] WITH(NOLOCK)
WHERE projectid= @projectId AND ExecutionId=@activeExecutionId 
AND ParentHierarchyId=@parentWorkItemTypeId
AND WorkItemTypeId <> 1 AND IsDeleted=0
)t1 

 

SELECT GWT.WorkTypeId, WorkTypeOrder,  
GWT.WorkTypeName AS WorkTypeName
FROM #tempProjectLevelWorkItemTypeId AS PLWT
INNER JOIN PP.ALM_MAS_WorkType AS GWT WITH(NOLOCK) 
ON PLWT.WorkItemTypeId=GWT.WorkTypeId
WHERE  IsDeleted=0
ORDER BY WorkTypeOrder ASC
END

 


END TRY 
 BEGIN CATCH
  DECLARE @hostName VARCHAR(15) = HOST_NAME()
  DECLARE @datenow DATETIME = GETDATE()
  DECLARE @projectNumber VARCHAR(10)=CONVERT(VARCHAR, @projectId)
  DECLARE @ErrorState VARCHAR(15)=CONVERT(VARCHAR, ERROR_STATE())
  DECLARE @ErrorMessage VARCHAR(MAX)=ERROR_MESSAGE()

 

  EXECUTE AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@hostName,@userId,@datenow,@projectNumber,
                                                 'SQL','ADM Way of Working','ALM Config',
                                                 'AppVisionLens','[ADM].[ALM_GetSubItemWorkItemTypeByExecutionMethod]',
                                                 @@SPID,@ErrorState,@ErrorMessage,'NULL','',''                                      
  END CATCH             
END
