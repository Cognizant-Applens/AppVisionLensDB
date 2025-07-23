/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================      
-- author:        
-- create date:       
-- Modified by : 835658      
-- Modified For: RHMS CR      
-- description: getting role details using customerID and userID      
-- =============================================      

CREATE procedure DE.GetRoles      
(          
@Mode VARCHAR(50)=NULL,            
@UserId VARCHAR(50)=NULL,            
@CustomerId BIGINT=NULL  
)
          
As            
Begin            
BEGIN TRY            
  
Declare @maxPriority int;  
Select @maxPriority = max(priority)+1 from RLE.VW_GetRoleMaster(NOLOCK) where Isdeleted=0       
SELECT AssociateId as EmployeeID,ApplensRoleID as RoleId,RoleName,RoleKey,PM.ProjectID,PM.ESAProjectId,        
PM.ProjectName,C.CustomerId,PM.Isdeleted as isActive,ISNULL([priority],@maxPriority) as [priority]  
INTO #VW_EmployeeCustomerProjectRoleBUMapping         
FROM RLE.VW_ProjectLevelRoleAccessDetails PRA(NOLOCK)        
INNER JOIN AVL.MAS_ProjectMaster (NOLOCK) PM ON PM.ESAPROJECTID=PRA.ESAProjectId and PM.Isdeleted=0        
INNER JOIN AVL.Customer (NOLOCK) C ON PM.CustomerID=C.CustomerID and c.isdeleted=0        
WHERE AssociateId=@UserId;            
           
   SELECT DISTINCT ApplensRoleid as RoleId,RoleName,RoleKey,isdeleted,ISNULL([priority],@maxPriority)    as [priority]     
    INTO #RoleMaster  FROM RLE.VW_GetRoleMaster(NOLOCK) where Isdeleted=0       
              
            
IF(@Mode='GetRoleUser')            
BEGIN            
SELECT DISTINCT ECPM.RoleId,ECPM.RoleName,[Priority] from                
  #VW_EmployeeCustomerProjectRoleBUMapping ECPM               
  WHERE  ECPM.EmployeeID=@UserId AND ECPM.CustomerID=@CustomerId         
END            
IF(@Mode='GetRoles')            
BEGIN            
 if exists(select DISTINCT RoleId,RoleName from                
 #VW_EmployeeCustomerProjectRoleBUMapping ECPM               
 WHERE ECPM.EmployeeID=@UserId and ECPM.Rolekey in('RLE015') and ECPM.CustomerID=@CustomerId)--SuperAdmin            
  BEgin             
  SELECT DISTINCT ApplensRoleid as RoleId,RoleName,[Priority]        
  FROM #RoleMaster where Isdeleted=0 order by Priority           
  END            
 Else if exists(select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from             
 #VW_EmployeeCustomerProjectRoleBUMapping ECPM             
 INNER JOIN #RoleMaster RM ON RM.RoleId=ECPM.RoleID            
 WHERE ECPM.EmployeeID=@UserId and RM.RoleKey in('RLE004') and ECPM.CustomerID=@CustomerId)--Admin            
  BEGIN             
   SELECT DISTINCT RoleId,RoleName,[Priority] FROM #RoleMaster where  RoleKey not in ('RLE015') order by Priority--'Proxy Admin'            
  End            
 Else if exists(select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from                
 #VW_EmployeeCustomerProjectRoleBUMapping ECPM             
 INNER JOIN #RoleMaster RM ON RM.RoleId=ECPM.RoleID            
 WHERE ECPM.EmployeeID=@UserId and RM.RoleKey not in('RLE004','RLE015') and ECPM.CustomerID=@CustomerId)--User            
  BEGIN             
   SELECT DISTINCT RoleId,RoleName,[Priority] FROM #RoleMaster where RM.RoleKey not in('RLE004','RLE015')  order by Priority            
  End            
            
          
  DROP TABLE IF EXISTS #UserRoleMapping          
  DROP TABLE IF EXISTS #VW_EmployeeCustomerProjectRoleBUMapping          
          
END            
END TRY              
 BEGIN CATCH              
            
  DROP TABLE IF EXISTS #UserRoleMapping          
  DROP TABLE IF EXISTS #VW_EmployeeCustomerProjectRoleBUMapping          
          
  DECLARE @ErrorMessage VARCHAR(MAX);            
            
  SELECT @ErrorMessage = ERROR_MESSAGE()            
            
  --INSERT Error                
  EXEC AVL_InsertError '[dbo].[GetRoles] ', @ErrorMessage,@CustomerId            
              
 END CATCH              
END
