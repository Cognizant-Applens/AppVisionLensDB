/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[CheckAssignmentGroupForproject] --10337,627119            
@ProjectID bigint,            
@EmployeeID varchar(20)            
as             
begin 
SET NOCOUNT ON;
begin try            
      
SELECT ESAprojectid INTO #temproletable FROM RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK) Where RoleKey in ('RLE015','RLE004','RLE005')      
      
select count(AssignmentGroupMapID) as AGCount from AVL.BOTAssignmentGroupMapping (NOLOCK)            
 where ProjectID=@ProjectID and AssignmentGroupCategoryTypeID=2 and IsBOTGroup=0 and IsDeleted=0             
            
select top 1 ESM.AccessWrite from AVL.EmployeeScreenMapping ESM (NOLOCK)           
join AVL.MAS_ProjectMaster Pm (NOLOCK) on Pm.CustomerID=ESM.CustomerID          
JOIN #temproletable PRA (NOLOCK) ON PRA.ESAprojectid=PM.ESAPROJECTid             
where ESM.EmployeeID=@EmployeeID and ESM.ScreenId=3 and pm.ProjectID=@ProjectID            
            
END TRY             
BEGIN CATCH            
DECLARE @ErrorMessage VARCHAR(MAX);            
SELECT            
 @ErrorMessage = ERROR_MESSAGE()            
EXEC AVL_InsertError '[AVL].[CheckAssignementGroupForprject]'            
      ,@ErrorMessage            
      ,0            
      ,0            
END CATCH   
SET NOCOUNT OFF;
end
