/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[sp_GetUserRoles]                         
@UserID nvarchar(max)                             
AS                           
BEGIN                          
BEGIN TRY                    
                    
DECLARE @ProjID varchar(50) = NULL                    
DECLARE @ProjName varchar(50) = NULL                    
DECLARE @CustomerID BIGINT = NULL                    
DECLARE @CustomerName varchar(50) = NULL                    
DECLARE @BUID varchar(50) = NULL                    
DECLARE @BUName varchar(50) = NULL                    
                    
CREATE TABLE #tempSource(                      
 RoleId [int] NOT NULL,                    
 RoleName nvarchar(max) NOT NULL,                        
-- AccessLevel nvarchar(50)  NOT NULL,                    
 EmployeeID nvarchar(50)  NOT NULL,                    
-- ProjectID  [int] NULL,                     
-- ProjectName varchar(200) NULL,                    
-- CustomerID [int] NULL,                     
-- CustomerName varchar(200) NULL,                     
-- BUID  [int] NULL,                     
-- BUName [varchar](200)  NULL,                   
-- UseParent [int] NULL,                  
-- ParentCustomerID [int] NULL,                  
-- ParentCustomerName [varchar](200)  NULL,                   
--UserRoleMappingID  [int] null                  
)                     
                    
SELECT                      
 rm.RoleId, rm.RoleName,                        
 alsm.AccessLevel,                    
 urm.EmployeeID,                     
 @ProjID as ProjectID,                     
 @ProjName as ProjectName,                     
 cus.CustomerID,                    
 cus.CustomerName,                     
 bu.BusinessUnitID as BUID,                     
 bu.BusinessUnitName as BUName,                  
     trn.UseParent AS UseParent,                                
       trn.parentID AS ParentCustomerID,                                 
       parent.parentcustomerName As  ParentCustomerName,                            
       URM.UserRoleMappingID                   
                           
INTO #tempAcc                     
 FROM [AVL].[UserRoleMapping] urm                        
 JOIN [AVL].[RoleMaster] rm                           
 ON urm.RoleID = rm.RoleId                         
 JOIN [AVL].[AccessLevelSourceMaster] alsm                          
 ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID                            
 JOIN [AVL].[Customer] cus                          
 ON urm.AccessLevelID =   cus.CustomerID                    
  --CASE WHEN alsm.AccessLevel = 'Account'                        
  --THEN cus.CustomerID                          
  --END                        
 JOIN [MAS].[BusinessUnits] bu                    
 ON cus.BusinessUnitID = bu.BusinessUnitID                    
left join [ESA].[BUParentAccounts] parent on cus.customerid=parent.customerid                
 left join businessoutcome.trn.accountlistmapping trn on trn.parentid=parent.parentcustomerid                 
 WHERE urm.IsActive = 1 AND   alsm.AccessLevel = 'Account'              
                    
 SELECT                      
 rm.RoleId, rm.RoleName,                        
 alsm.AccessLevel, urm.EmployeeID, @ProjID as ProjectID, @ProjName as ProjectName, @CustomerID as CustomerID, @CustomerName as Customername, bu.BusinessUnitID, bu.BusinessUnitName                   
 , trn.UseParent AS UseParent,                                
   trn.parentID AS ParentCustomerID,                                 
   parent.parentcustomerName As  ParentCustomerName,                            
   URM.UserRoleMappingID                     
 INTO #tempBU                     
 FROM [AVL].[UserRoleMapping] urm                        
 JOIN [AVL].[RoleMaster] rm                           
 ON urm.RoleID = rm.RoleId                         
  JOIN [AVL].[AccessLevelSourceMaster] alsm                          
 ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID                            
 JOIN [MAS].[BusinessUnits] bu                        
 ON urm.AccessLevelID =                        
  CASE WHEN alsm.AccessLevel = 'BU'  OR alsm.AccessLevel = 'Sub Horizontal'                       
  THEN bu.BusinessUnitID                          
  END                    
left  JOIN [Businessoutcome].[TRN].[Accountlistmapping] trn                                
on  urm.UserRoleMappingId=trn.USerRoleMappingID                                
 left JOIN [ESA].[BUParentAccounts] parent on trn.parentid=parent.parentcustomerid                       
 WHERE urm.IsActive = 1                    
                    
 SELECT                 
 rm.RoleId, rm.RoleName, alsm.AccessLevel,urm.EmployeeID,                     
 pm.ProjectID as ProjectID, pm.ProjectName as ProjectName, cus.CustomerID, cus.CustomerName, bu.BusinessUnitID, bu.BusinessUnitName,                
trn.UseParent AS UseParent, trn.parentID AS ParentCustomerID, parent.parentcustomerName As  ParentCustomerName,                            
   URM.UserRoleMappingID                      
INTO #tempProject                     
 FROM [AVL].[UserRoleMapping] urm                        
 JOIN [AVL].[RoleMaster] rm                           
 ON urm.RoleID = rm.RoleId                         
 JOIN [AVL].[AccessLevelSourceMaster] alsm                          
 ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID                            
  JOIN [AVL].MAS_ProjectMaster pm                           
 ON urm.AccessLevelID = pm.ProjectID                         
  --CASE WHEN alsm.AccessLevel = 'Project'                        
  --THEN pm.ProjectID                          
  --END                    
 JOIN [AVL].[Customer] cus                        
 ON pm.CustomerID = cus.CustomerID                    
 JOIN [MAS].[BusinessUnits] bu                          
 ON cus.BusinessUnitID = bu.BusinessUnitID                     
 left join [ESA].[BUParentAccounts] parent on cus.customerid=parent.customerid                
 left join businessoutcome.trn.accountlistmapping trn on trn.parentid=parent.parentcustomerid                 
 WHERE urm.IsActive = 1 AND alsm.AccessLevel = 'Project'--and employeeid = 627122                   
                    
 SELECT                      
 rm.RoleId, rm.RoleName,                        
 alsm.AccessLevel, urm.EmployeeID, @ProjID as ProjectID, @ProjName as ProjectName, @CustomerID as CustomerID, @CustomerName as CustomerName, @BUID as BUID, @BUName as BUName                  
 ,trn.UseParent AS UseParent,                                
   trn.parentID AS ParentCustomerID,                                 
   parent.parentcustomerName As  ParentCustomerName,                            
   URM.UserRoleMappingID                    
 INTO #tempHorizontal                    
 FROM [AVL].[UserRoleMapping] urm                        
 JOIN [AVL].[RoleMaster] rm                           
 ON urm.RoleID = rm.RoleId                         
 JOIN [AVL].[AccessLevelSourceMaster] alsm                          
 ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID                    
  left JOIN [Businessoutcome].[TRN].[Accountlistmapping] trn                                
on  urm.UserRoleMappingId=trn.USerRoleMappingID                                
left JOIN [ESA].[BUParentAccounts] parent on trn.parentid=parent.parentcustomerid                      
 WHERE alsm.AccessLevel = 'Horizontal' AND urm.IsActive = 1                    
                    
                    
-- SELECT                      
-- rm.RoleId, rm.RoleName,                        
-- alsm.AccessLevel, urm.EmployeeID, @ProjID as ProjectID, @ProjName as ProjectName, @CustomerID as CustomerID, @CustomerName as CustomerName, bu.BUID, bu.BUName                  
-- ,trn.UseParent AS UseParent,                                
--   trn.parentID AS ParentCustomerID,                                 
--   parent.parentcustomerName As  ParentCustomerName,                  
--   URM.UserRoleMappingID                      
-- INTO #tempSubHorizontal                    
-- FROM [AVL].[UserRoleMapping] urm                        
-- JOIN [AVL].[RoleMaster] rm                           
-- ON urm.RoleID = rm.RoleId                         
-- JOIN [AVL].[AccessLevelSourceMaster] alsm                          
-- ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID            
-- JOIN [MAS].[BusinessUnits] bu                        
-- ON urm.AccessLevelID =                        
--    CASE WHEN alsm.AccessLevel = 'Sub Horizontal'                        
--    THEN bu.BUID                          
--    END                    
--   left  JOIN [Businessoutcome].[TRN].[Accountlistmapping] trn                                
--on  urm.UserRoleMappingId=trn.USerRoleMappingID                                
-- left JOIN [ESA].[BUParentAccounts] parent on trn.parentid=parent.parentcustomerid                        
-- WHERE urm.IsActive = 1                    
                  
 INSERT INTO #tempSource                      
 SELECT RoleId, RoleName,EmployeeID  FROM #tempAcc                      
 UNION                    
 SELECT RoleId, RoleName,EmployeeID FROM #tempBU                      
 UNION                    
 SELECT RoleId, RoleName,EmployeeID FROM #tempProject                      
 UNION                    
 SELECT RoleId, RoleName,EmployeeID FROM #tempHorizontal                      
 --UNION                    
 --SELECT RoleId, RoleName, AccessLevel, EmployeeID, ProjectID, ProjectName, CustomerID, CustomerName, BUID, BUName,UseParent,ParentCustomerID,ParentCustomerName,UserRoleMappingID FROM #tempSubHorizontal                    
                    
 --select * from  #tempSource           
 declare @RoleID int, @Rolename varchar(max), @Count int = 0       
 select @RoleID=RoleId, @Rolename=RoleName from avl.RoleMaster where RoleId=12        
       
 select @Count = count(*) from avl.userrolemapping urm        
inner join avl.RoleMaster rm on rm.RoleId = urm.RoleID and rm.RoleId = @RoleID        
 where urm.EmployeeID=@UserID and urm.IsActive=1       
       
 if(@Count > 0)        
 insert into #tempSource values (@RoleID, @Rolename,@UserID)             
                    
 SELECT RoleId, RoleName from #tempSource                     
 where EmployeeID = @UserID                    
                    
 DROP TABLE #tempAcc                      
 DROP TABLE #tempBU                      
 DROP TABLE #tempProject                    
 DROP TABLE #tempHorizontal                      
 --DROP TABLE #tempSubHorizontal                    
 DROP TABLE #tempSource                    
                      
 END TRY                       
 BEGIN CATCH                        
                         
  DECLARE @ErrorMessage VARCHAR(MAX);                        
  SELECT @ErrorMessage = ERROR_MESSAGE()                        
  --INSERT Error                            
  EXEC AVL_InsertError '[AVL].[BOM_GetAccessDetailsByUserID]', @ErrorMessage,0                      
                          
 END CATCH                          
                      
END
