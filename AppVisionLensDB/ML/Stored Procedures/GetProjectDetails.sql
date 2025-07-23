/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================        
-- Author      : 835658       
-- Create date : May 11, 2021        
-- Description : Get the Top Filters By EmployeeID            
-- Revision    :        
-- Revised By  :        
-- =========================================================================================        
--[ML].[GetProjectDetails] '659978' 
CREATE PROCEDURE [ML].[GetProjectDetails]  
@EmployeeID varchar(100)        
AS          
BEGIN              
BEGIN TRY              
 SET NOCOUNT ON;              
        
  SELECT ESAProjectId,Associateid,Rolekey  INTO #temproletable FROM RLE.VW_ProjectLevelRoleAccessDetails PL WITH(NOLOCK)       
  WHERE  PL.Associateid =@EmployeeID AND PL.Rolekey='RLE003'   
        
      
  SELECT PM.ProjectID AS ID,PM.ProjectName AS Name,PM.ESAProjectID,PM.IsCoginzant,PC.SupportTypeId  FROM #temproletable L (NOLOCK)              
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.EsaProjectID=L.ESAProjectId               
  INNER JOIN AVL.MAS_PROJECTDEBTDETAILS (NOLOCK) PDD ON PDD.ProjectID = PM.ProjectID              
  INNER JOIN AVL.MAP_ProjectConfig (NOLOCK) PC ON PM.ProjectID=PC.ProjectID AND PC.SupportTypeId IN (1,2,3)              
  WHERE --(L.HcmSupervisorID = @EmployeeID or  L.TSApproverID =  @EmployeeID)            
   ISNULL(PM.IsDeleted,0)=0               
  UNION             
   SELECT distinct PM.ProjectID,PM.ProjectName,PM.ESAProjectID,PM.IsCoginzant,PC.SupportTypeId            
     FROM #temproletable PRA                 
    INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PRA.ESAProjectId=PM.ESAProjectId and PM.isdeleted=0              
 INNER JOIN AVL.MAS_PROJECTDEBTDETAILS (NOLOCK)PDD ON PDD.ProjectID = PM.ProjectID              
 INNER JOIN AVL.MAP_ProjectConfig (NOLOCK)PC ON PM.ProjectID=PC.ProjectID AND PC.SupportTypeId IN (1,2,3)  
 Where RoleKey = 'RLE003'         -- 3 project level            
  UNION              
   SELECT distinct PM.ProjectID,PM.ProjectName,PM.ESAProjectID,PM.IsCoginzant,PC.SupportTypeId             
     FROM #temproletable PRA                 
    INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PRA.ESAProjectId=PM.ESAProjectId and PM.isdeleted=0              
 INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerId AND C.IsDeleted=0             
 INNER JOIN AVL.MAS_PROJECTDEBTDETAILS PDD ON PDD.ProjectID = PM.ProjectID              
 INNER JOIN AVL.MAP_ProjectConfig PC ON PM.ProjectID=PC.ProjectID AND PC.SupportTypeId IN (1,2,3)             
 WHERE RoleKey = 'RLE003' and C.IsDeleted = 0 AND PM.IsDeleted = 0 --3 Account        
       
 IF EXISTS(SELECT top 11 Associateid from #temproletable)      
 BEGIN      
 DROP TABLE #temproletable      
 END      
                         
END TRY              
BEGIN Catch              
   DECLARE @ErrorMessage VARCHAR(MAX);              
   SELECT @ErrorMessage = ERROR_MESSAGE()              
   --INSERT Error                  
   EXEC AVL_InsertError '[ML].[GetProjectDetails] ', @ErrorMessage,@EmployeeID              
              
End Catch              
END
