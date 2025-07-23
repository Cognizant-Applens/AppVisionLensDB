/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROC [AVL].[GetSupervisorAndEmployeeList]         
@ProjectID BIGINT=NULL        
AS        
BEGIN        
SET NOCOUNT ON;        
BEGIN TRY        
  
SELECT DISTINCT ProjectID,CustomerID,EmployeeID AS HcmSupervisorID  
FROM  AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID   
AND isdeleted=0 AND EmployeeID IS NOT NULL   
Union  
SELECT DISTINCT ProjectID,CustomerID,HcmSupervisorID  
FROM  AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID  
AND isdeleted=0 AND HcmSupervisorID IS NOT NULL   
  
END TRY           
BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  --INSERT Error            
  EXEC AVL_InsertError '[AVL].[GetSupervisorAndEmployeeList]', @ErrorMessage, 'system',0        
          
 END CATCH   
 SET NOCOUNT OFF;  
END
