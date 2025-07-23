/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetImportmailUser (@EsaProjectID NVARCHAR(100))
AS
BEGIN 
BEGIN TRY   

DECLARE @ProjectID BIGINT

	SET @ProjectID = (SELECT ProjectId  FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ESAProjectId = @EsaProjectID AND IsDeleted = 0)

	SELECT DISTINCT EmployeeEmail FROM avl.MAS_LoginMaster(NOLOCK) WHERE 
	EmployeeId IN (
					select  AssociateId from[RLE].[VW_UserRoleMappingDataAccess] URM 
					inner join MAS.RLE_Roles Rol on Rol.ApplensRoleID=URM.ApplensRoleID and Rol.RoleKey in ('RLE004','RLE005')
					where URM.ProjectID = @ProjectID
							)AND IsDeleted=0 and ProjectID = @ProjectID
END TRY
 BEGIN CATCH    

  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[GetImportmailUser] ', @ErrorMessage, @ProjectID  
    
END CATCH  
END
