/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ====================================================================    
-- author:      
-- create date:     
-- Modified by : 835658    
-- Modified For: RHMS New Role API   
-- description: getting customer status details using employeeid and projectID    
-- ====================================================================    
    
-- EXEC [AVL].[WorkEffort_GetCustomerStatusByProjectID] '104559',90524    
    
CREATE PROCEDURE [AVL].[WorkEffort_GetCustomerStatusByProjectID]    
(                     
    @EmployeeId VARCHAR(20)='',    
    @ProjectID VARCHAR(MAX)      
)    
     
AS    
BEGIN      
BEGIN TRY     
  SET NOCOUNT ON;     
SELECT TOP 1  C.IsCognizant     
  FROM         
   RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)PRA    
   JOIN AVL.Customer (NOLOCK) C ON C.ESA_AccountId=PRA.ESACustomerId and c.IsDeleted=0  
   JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON C.CustomerID=PM.CustomerId  and PM.Isdeleted=0 
   WHERE PRA.AssociateId=@EmployeeId AND PM.ProjectId=@ProjectID    
    
 SET NOCOUNT OFF;     
   END TRY    
    
  BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
  --INSERT Error        
  EXEC AVL_InsertError '[AVL].[WorkEffort_GetCustomerStatusByProjectID]', @ErrorMessage, @ProjectID,@EmployeeId    
  RETURN @ErrorMessage    
  END CATCH       
END
