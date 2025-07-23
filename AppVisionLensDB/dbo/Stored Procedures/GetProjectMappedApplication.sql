/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetProjectMappedApplication (@ProjectID BIGINT) 
AS 
BEGIN 
BEGIN TRY  
  
	SELECT App.ApplicationId AS ApplicationId,App.ApplicationName AS ApplicationName FROM AVL.APP_MAS_ApplicationDetails App WITH(NOLOCK)   
		JOIN AVL.APP_MAP_ApplicationProjectMapping AppProj WITH(NOLOCK) ON App.ApplicationId = AppProj.ApplicationId  
		JOIN ADM.AppApplicationScope AppApplScope WITH(NOLOCK) ON AppApplScope.ApplicationId =  App.ApplicationID   
		JOIN ADM.ApplicationScope ApplScope WITH(NOLOCK) ON AppApplScope.ApplicationScopeId  = ApplScope.ID  
	WHERE AppProj.ProjectId = @ProjectID 
		  AND AppProj.IsDeleted = 0 
		  AND App.IsActive = 1 
		  AND ApplScope.Id = 1 
		  AND ApplScope.IsDeleted = 0 
		  AND AppApplScope.IsDeleted = 0  
	ORDER BY App.ApplicationId  
END TRY 
BEGIN CATCH    
  
DECLARE @ErrorMessage VARCHAR(MAX);  
  
SELECT @ErrorMessage = ERROR_MESSAGE()  
  
--INSERT Error      
EXEC AVL_InsertError 'GetProjectMappedApplication ', @ErrorMessage, @ProjectID  
    
END CATCH  END
