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
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting role details using customerID and userID
-- =============================================


--exec [dbo].[GetRoles] 'GetRoles','104559',7297
--exec [dbo].[GetRoles] 'GetRoleUser','104559',7297

CREATE Proc [dbo].[GetRoles]  
(  
@Mode VARCHAR(50)=NULL,  
@UserId VARCHAR(50)=NULL,  
@CustomerId BIGINT=NULL  
)  
As  
Begin  
SET NOCOUNT ON;
BEGIN TRY  
  
SELECT EmployeeID,RoleID,AccessLevelID,AccessLevelSourceID,IsActive INTO #UserRoleMapping FROM AVL.UserRoleMapping (NOLOCK) WHERE EmployeeID=@UserId AND IsActive=1;  
  
SELECT   
DISTINCT URM.EmployeeID,  
URM.AccessLevelID ,  
COALESCE(PM.ProjectID,PM1.ProjectID,PM2.ProjectID) AS ProjectID,  
COALESCE(PM.EsaProjectID,PM1.EsaProjectID,PM2.EsaProjectID) AS ESAProjectID,  
COALESCE(PM.ProjectName,PM1.ProjectName,PM2.ProjectName) AS ProjectName,  
COALESCE(PM.CustomerID,C.CustomerID,C1.CustomerID) AS CustomerID,  
URM.RoleID  
INTO #VW_EmployeeCustomerProjectRoleBUMapping  
FROM #UserRoleMapping URM (NOLOCK)  
LEFT JOIN [MAS].[BusinessUnits] bu (NOLOCK) on URM.AccessLevelID = bu.BusinessUnitID AND URM.AccessLevelSourceID=2  
LEFT JOIN AVL.Customer C1 (NOLOCK) on c1.BusinessUnitID=bu.BusinessUnitID and C1.IsDeleted<>1  
LEFT JOIN AVL.MAS_ProjectMaster PM2 (NOLOCK) on pm2.CustomerID=c1.CustomerID and PM2.IsDeleted<>1  
LEFT JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON URM.AccessLevelID = PM.ProjectID AND URM.AccessLevelSourceID=4 and PM.IsDeleted<>1  
LEFT JOIN AVl.Customer C (NOLOCK) ON URM.AccessLevelID= C.CustomerID AND URM.AccessLevelSourceID=3 and C.IsDeleted<>1  
LEFT JOIN AVL.MAS_ProjectMaster PM1 (NOLOCK) ON PM1.CustomerID=C.CustomerID AND PM1.CustomerID=URM.AccessLevelID and PM1.IsDeleted<>1  
WHERE URM.IsActive=1  
  
  
IF(@Mode='GetRoleUser')  
BEGIN  
  select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from   
  --[AVL].[EmployeeCustomerMapping](NOLOCK) LM   
  --INNER JOIN [AVL].[EmployeeRoleMapping](NOLOCK) URM on LM.Id=URM.EmployeeCustomerMappingid  
  #VW_EmployeeCustomerProjectRoleBUMapping (NOLOCK) ECPM   
  INNER JOIN AVL.RoleMaster(NOLOCK) RM ON RM.RoleId=ECPM.RoleID  
  WHERE  ECPM.EmployeeID=@UserId AND ECPM.CustomerID=@CustomerId  
END  
IF(@Mode='GetRoles')  
BEGIN  
 if exists(select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from   
 --[AVL].[EmployeeCustomerMapping](NOLOCK) LM   
 --INNER JOIN [AVL].[EmployeeRoleMapping] (NOLOCK) URM on LM.Id=URM.EmployeeCustomerMappingid  
 #VW_EmployeeCustomerProjectRoleBUMapping (NOLOCK) ECPM   
 INNER JOIN AVL.RoleMaster (NOLOCK) RM ON RM.RoleId=ECPM.RoleID  
 WHERE ECPM.EmployeeID=@UserId and RM.RoleId in(1) and ECPM.CustomerID=@CustomerId and RM.isactive=1)--SuperAdmin  
  BEgin   
   SELECT DISTINCT RoleId,RoleName,[Priority] FROM AVL.RoleMaster(NOLOCK) where IsActive=1 order by Priority--and RoleId not in (7)  
  END  
 Else if exists(select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from   
 --[AVL].[EmployeeCustomerMapping](NOLOCK) LM   
 --INNER JOIN [AVL].[EmployeeRoleMapping](NOLOCK) URM on LM.Id=URM.EmployeeCustomerMappingid  
 #VW_EmployeeCustomerProjectRoleBUMapping (NOLOCK) ECPM   
 INNER JOIN AVL.RoleMaster(NOLOCK) RM ON RM.RoleId=ECPM.RoleID  
 WHERE ECPM.EmployeeID=@UserId and RM.RoleId in(6) and ECPM.CustomerID=@CustomerId and RM.isactive=1)--Admin  
  BEGIN   
   SELECT DISTINCT RoleId,RoleName,[Priority] FROM AVL.RoleMaster(NOLOCK) where IsActive=1 and RoleId not in (1)  order by Priority--'Proxy Admin'  
  End  
 Else if exists(select DISTINCT RM.RoleId,RM.RoleName,RM.Priority from   
 --[AVL].[EmployeeCustomerMapping](NOLOCK) LM   
 --INNER JOIN [AVL].[EmployeeRoleMapping](NOLOCK) URM on LM.Id=URM.EmployeeCustomerMappingid  
 #VW_EmployeeCustomerProjectRoleBUMapping (NOLOCK) ECPM   
 INNER JOIN AVL.RoleMaster(NOLOCK) RM ON RM.RoleId=ECPM.RoleID  
 WHERE ECPM.EmployeeID=@UserId and RM.RoleId not in(6,1) and ECPM.CustomerID=@CustomerId and RM.isactive=1)--User  
  BEGIN   
   SELECT DISTINCT RoleId,RoleName,[Priority] FROM AVL.RoleMaster(NOLOCK) where IsActive=1 and RoleId not in (1,6)  order by Priority  
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
 SET NOCOUNT OFF;
END
