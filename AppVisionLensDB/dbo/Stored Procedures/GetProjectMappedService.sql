/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetProjectMappedService (@ProjectID BIGINT) 
AS 
BEGIN 
BEGIN TRY  
	SELECT serviceActive.ServiceId,serviceActive.ServiceName FROM AVL.TK_MAS_ServiceActivityMapping serviceActive WITH(NOLOCK)  
		JOIN AVL.TK_PRJ_ProjectServiceActivityMapping serviceProject WITH(NOLOCK) ON serviceProject.ServiceMapID = serviceActive.ServiceMappingID  
		JOIN AVL.TK_MAS_Service serviceMas WITH(NOLOCK) ON serviceMas.ScopeID = serviceActive.ServiceID  
		JOIN MAS.PPScope Pp WITH(NOLOCK) ON serviceMas.ScopeId = Pp.ScopeId  
	WHERE serviceProject.ProjectId = @ProjectID AND  serviceProject.IsDeleted = 0 AND  
		serviceActive.IsDeleted = 0 AND (serviceMas.ScopeId = 1 OR serviceMas.ScopeId = 3)  
	ORDER BY serviceActive.ServiceName  
 END TRY 
 BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError 'GetProjectMappedService ', @ErrorMessage, @ProjectID  
    
END CATCH  
END
