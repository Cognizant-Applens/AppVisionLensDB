/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
      
CREATE PROCEDURE [AVL].[GetProjectCustomer] --'842416',2  
@EmployeeID NVARCHAR(50),  
@Mode SMALLINT  
AS      
BEGIN     
SET NOCOUNT ON;   
IF(@Mode = 1)  
BEGIN  
SELECT DISTINCT CustomerId  
FROM AVL.MAS_LoginMaster(NOLOCK)   
WHERE (Employeeid = @EmployeeId OR TSApproverID = @EmployeeId OR
HcmSupervisorID = @EmployeeID)  and IsDeleted = 0  
END  
ELSE  
BEGIN  
SELECT DISTINCT ProjectId  
FROM AVL.MAS_LoginMaster(NOLOCK)   
WHERE (Employeeid = @EmployeeId OR TSApproverID = @EmployeeId OR
HcmSupervisorID = @EmployeeID)  AND IsDeleted = 0  
END  
END
