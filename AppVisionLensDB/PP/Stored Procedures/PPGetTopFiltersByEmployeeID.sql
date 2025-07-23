      
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
-- Create date : May 10, 2021                                          
-- Description : Get the Top Filters By EmployeeID                                              
-- Revision    :                                          
-- Revised By  :                                          
-- =========================================================================================                                          
                                        
                                          
CREATE PROCEDURE [PP].[PPGetTopFiltersByEmployeeID]  --'823169'                                       
@AssociateID NVARCHAR(50)                                              
                                              
AS                                               
  BEGIN                                               
 BEGIN TRY                                               
  SET NOCOUNT ON;                  
              
UPDATE avl.mas_loginmaster set EmployeeId=TRIM(EmployeeId) where EmployeeId=@AssociateID and IsDeleted=0            
                    
select Associateid,VerticalID,VerticalName,BusinessUnitID,BusinessUnitName,                        
ESAProjectID,Projectid,projectname,Customerid,CustomerName,ESACustomerID,                        
ApplensRoleID,RoleName,RoleKey,Datasource,isdeleted,priority,GroupName , AssociateName,Email,RoleMappingID   into #tempAssociateRoleData                        
FROM RLE.VW_ProjectLevelRoleAccessDetails(NOLOCK) ecpm                         
Where ecpm.Associateid = @AssociateID                    
                                  
   --Section 1 :- Getting the EmployeeID & EmployeeName                                              
   SELECT DISTINCT TOP 1 Associateid AS ID,AssociateName AS Name                                              
   FROM #tempAssociateRoleData(NOLOCK)                    
                       
                    
                                              
   --BU                                              
   CREATE TABLE #BUAccountProjectInfo                                              
   (                                              
   ParentId BIGINT NULL,                                              
   Id BIGINT NULL,                                              
   Name NVARCHAR(50) NULL,                                              
   LevelId int null,                                            
   RoleID INT null,                                              
   EsaProjectID BIGINT null                                            
   )                                              
                      
   INSERT INTO #BUAccountProjectInfo                                              
   SELECT DISTINCT 0 AS ParentID,PRA.BusinessUnitID AS ID,PRA.BusinessUnitName AS [Name],1 as LevelID,ApplensRoleID as RoleID,0 as EsaProjectID                                              
  FROM #tempAssociateRoleData(NOLOCK) PRA                                                               
    WHERE ROLEKEY IN('RLE004','RLE005','RLE015')--'RLE052')   ---2 as BU     AND  ISNULL(PRA.BusinessUnitID,0)!=0                                        
                                              
   INSERT INTO #BUAccountProjectInfo                                              
   SELECT DISTINCT PRA.BusinessUnitID as ParentID,C.CustomerID AS ID,C.CustomerName AS [Name],2 as LevelID,ApplensRoleID as RoleID,0 AS EsaProjectID                                             
    FROM #tempAssociateRoleData(NOLOCK) PRA                                                             
      INNER JOIN AVL.Customer(NOLOCK) C ON PRA.ESACustomerID=C.ESA_AccountID AND C.IsDeleted=0  And PRA.Customerid = C.Customerid                                             
    WHERE   ROLEKEY IN('RLE004','RLE005','RLE015') --'RLE052')     --3 as Account                                            
   --AND  c.IsCognizant = 1                                              
                                              
   INSERT INTO #BUAccountProjectInfo                                              
   SELECT DISTINCT PM.CustomerID as ParentID,PM.ProjectID AS ID,PM.ProjectName  AS [Name],3 as LevelID,ApplensRoleId as RoleID,PM.EsaProjectID                                            
     FROM #tempAssociateRoleData(NOLOCK) PRA                                               
     INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PRA.ESAProjectId=PM.ESAProjectId and PM.isdeleted=0                               
    WHERE  ROLEKEY IN('RLE004','RLE005','RLE015') AND PM.EsaProjectID != '0'     --4 as project                                            
                                            
    SELECT DISTINCT ParentID,Id,[Name],LevelID,RoleID,EsaProjectID FROM #BUAccountProjectInfo (NOLOCK)              
ORDER BY Id DESC          
                                              
 SELECT DISTINCT PRA.ApplensRoleId as RoleId,PRA.RoleName,RoleKey,[Priority]                                                            
     FROM #tempAssociateRoleData (NOLOCK) PRA                                     
     INNER join #BUAccountProjectInfo (NOLOCK) BA ON PRA.ApplensRoleid=BA.Roleid                                
                                             
 END TRY                                               
                                              
    BEGIN CATCH                                               
        DECLARE @ErrorMessage VARCHAR(MAX);                                               
       SELECT @ErrorMessage = ERROR_MESSAGE()                                               
        --INSERT Error                                
        EXEC AVL_INSERTERROR  '[PP].[PPGetTopFiltersByEmployeeID]', @ErrorMessage,  0,                                               
        0                                      
    END CATCH       
SET NOCOUNT OFF;      
DROP TABLE #tempAssociateRoleData    
DROP TABLE #BUAccountProjectInfo       
  END
