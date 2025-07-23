/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CheckForSuperAdmin]              
@UserID nvarchar(50),  
@IsSuperAdmin char output                 
AS               
BEGIN              
BEGIN TRY        
   
IF EXISTS(SELECT 1 FROM [AVL].[UserRoleMapping]  
                        WHERE EmployeeId = @UserID and IsActive=1 and RoleID = 1)  
      BEGIN  
            SET @IsSuperAdmin = 1  
      END  
      ELSE  
      BEGIN  
            SET @IsSuperAdmin = 0  
      END   
  
    END TRY           
 BEGIN CATCH            
             
  DECLARE @ErrorMessage VARCHAR(MAX);            
  SELECT @ErrorMessage = ERROR_MESSAGE()            
  --INSERT Error                
  EXEC AVL_InsertError '[AVL].[[CheckForSuperAdmin]]', @ErrorMessage,0          
              
 END CATCH              
          
END
