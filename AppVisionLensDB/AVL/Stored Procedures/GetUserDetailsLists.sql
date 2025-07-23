/***************************************************************************                    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET                    
*Copyright [2018] – [2021] Cognizant. All rights reserved.                    
*NOTICE: This unpublished material is proprietary to Cognizant and                    
*its suppliers, if any. The methods, techniques and technical                    
  concepts herein are considered Cognizant confidential and/or trade secret information.                     
                      
*This material may be covered by U.S. and/or foreign patents or patent applications.                     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.                    
***************************************************************************/                    
                              
-- =========================================================================================                              
-- Author      : 835658                             
-- Create date : 2021                              
-- Description : Get the Top Filters By EmployeeID                                  
-- Revision    :                              
-- Revised By  :                              
-- =========================================================================================                              
   
CREATE PROCEDURE [AVL].[GetUserDetailsLists] --'41844'       
@ProjectID bigint   
AS              
BEGIN                                 
 BEGIN TRY                                 
  SET NOCOUNT ON;        
   
    select DISTINCT Associateid,ESAProjectID,projectname,Projectid from RLE.VW_ProjectLevelRoleAccessDetails         
       where  ROLEKEY IN('RLE004','RLE005','RLE015') and Projectid=@ProjectID  and isDeleted=0   
 
          
   END TRY                                
   BEGIN CATCH                                 
    DECLARE @ErrorMessage VARCHAR(MAX);                                 
    SELECT @ErrorMessage = ERROR_MESSAGE()                                 
    --INSERT Error                                     
    EXEC AVL_INSERTERROR  '[AVL].[GetUserDetailsLists]', @ErrorMessage,  0, 0                                 
   END CATCH                                 
 END
