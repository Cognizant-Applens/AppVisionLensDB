/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [ADM].[ALM_GetBacklogApplicationsByExecutionMethod]
(
@userId VARCHAR(50),
@projectId BIGINT,
@applicationId BIGINT=0
)
AS            
BEGIN     
BEGIN TRY       
SET NOCOUNT ON; 

DECLARE @tempProjectLevelExecutionMethod TABLE (
ExecutionMethod BIGINT
)

IF(@applicationId <> 0)
BEGIN

INSERT INTO @tempProjectLevelExecutionMethod 
SELECT Distinct AttributeValueID AS ExecutionMethod
FROM PP.ProjectAttributeValues(NOLOCK)
WHERE projectid= @projectId AND AttributeID=3 AND
AttributeValueID IN (SELECT ExecutionMethod FROM [ADM].[ALMApplicationDetails](NOLOCK) 
WHERE ApplicationID=@applicationId AND IsDeleted=0)
AND IsDeleted=0 

END
ELSE
BEGIN

INSERT INTO @tempProjectLevelExecutionMethod 
SELECT Distinct AttributeValueID AS ExecutionMethod
FROM PP.ProjectAttributeValues(NOLOCK)
WHERE projectid= @projectId AND AttributeID=3  AND IsDeleted=0

END


SELECT * INTO #tempValidApplications FROM (
SELECT Distinct ALE.ApplicationID
FROM @tempProjectLevelExecutionMethod  AS PLE
INNER JOIN [ADM].[ALMApplicationDetails](NOLOCK) AS ALE
ON PLE.ExecutionMethod=ALE.ExecutionMethod
INNER JOIN [PP].[ALM_MAP_GenericWorkItemConfig](NOLOCK)  AS GWIC
ON PLE.ExecutionMethod=GWIC.ExecutionId
WHERE GWIC.projectid= @projectId AND GWIC.WorkItemTypeId <> 1
AND GWIC.IsDeleted=0 AND ALE.IsDeleted=0
)t2 

SELECT Distinct AMAS.ApplicationId,AMAS.ApplicationName
FROM #tempValidApplications(NOLOCK) AS TVP
INNER JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AS AMAS
ON TVP.ApplicationID=AMAS.ApplicationId
INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) AS APM
ON TVP.ApplicationID=APM.ApplicationId
INNER JOIN ADM.AppApplicationScope(NOLOCK) AS ASP
ON TVP.ApplicationID=ASP.ApplicationID
WHERE APM.ProjectID=@projectId AND ASP.ApplicationScopeId=1 AND ASP.IsDeleted=0
AND APM.IsDeleted=0 AND AMAS.IsActive=1

SET NOCOUNT OFF;
END TRY 
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[ALM_GetBacklogApplicationsByExecutionMethod] ', @ErrorMessage, @userId,@projectId
		RETURN @ErrorMessage
  END CATCH             
END
