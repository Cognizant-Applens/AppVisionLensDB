/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetEmployeeInfo  -- 694563,7097    
(      
@EmployeeID nvarchar(100),      
@CustomerID bigint      
)      
AS      
Begin      
BEGIN TRY       
      
-- Project PM and TS Approver of the Employee      
      
select PM.ProjectName,P.ProjectManagerID, LM.TSApproverID into #ProjectDetails from AVL.MAS_LoginMaster LM      
inner join AVL.MAS_ProjectMaster PM on LM.ProjectID=PM.ProjectID      
inner join ESA.Projects P on PM.EsaProjectID = P.ID      
where LM.EmployeeID=@EmployeeID and LM.CustomerID=@CustomerID and LM.IsDeleted=0 and PM.IsDeleted=0      
    
--where LM.EmployeeID=694563 and LM.CustomerID=7097 and LM.IsDeleted=0 and PM.IsDeleted=0      
      
      
-- Customer level Admins and proxy admins      
      
--select C.CustomerName, UM.EmployeeID from AVL.UserRoleMapping UM      
--inner join AVL.Customer C on UM.AccessLevelID=C.CustomerID      
--where UM.IsActive=1 and UM.RoleID in (6,7) and UM.AccessLevelSourceID=3 and UM.AccessLevelID=@CustomerID -- and UM.DataSource in('ESA' )      
     
     
-- Project level Admins and Proxy Admins      
      
select distinct PM.ProjectName, UM.EmployeeID  into #AdminDetails from AVL.UserRoleMapping UM      
inner join AVL.MAS_LoginMaster LM on UM.AccessLevelID=LM.ProjectID      
inner join AVL.MAS_ProjectMaster PM on LM.ProjectID=PM.ProjectID      
inner join ESA.Projects P on PM.EsaProjectID = P.ID      
where LM.EmployeeID=@EmployeeID and LM.CustomerID=@CustomerID and LM.IsDeleted=0      
--where LM.EmployeeID=694563 and LM.CustomerID=7097 and LM.IsDeleted=0      
and PM.IsDeleted=0 and UM.IsActive=1 and UM.AccessLevelSourceID=4 and UM.RoleID in (6,7)-- and UM.DataSource in('ESA' )      
      
    
     
 SELECT DISTINCT ProjectName, EmployeeIDs into #AdminList    
FROM #AdminDetails v1    
CROSS APPLY ( SELECT top 5 EmployeeID + ', '     
              FROM #AdminDetails v2    
              WHERE v2.ProjectName = v1.ProjectName 
			   order by v2.EmployeeID    
                  FOR XML PATH('') )  D ( EmployeeIDs )    
    
    
    
--select PD.*,AL.EmployeeIDs from #ProjectDetails PD    
--inner join  #AdminList AL on PD.ProjectName=AL.ProjectName    
    
  
  select case  
when right(rtrim(EmployeeIDs),1) = ',' then substring(rtrim(EmployeeIDs),1,len(rtrim(EmployeeIDs))-1)  
else EmployeeIDs END AS EmployeeIDs ,PD.*  
From #AdminList as AL inner join  #ProjectDetails PD on PD.ProjectName=AL.ProjectName   
  
drop table #ProjectDetails    
    
drop table #AdminDetails    
    
drop table #AdminList    
    
    
    
    
    
    
    
    
    
    
END TRY      
      
BEGIN CATCH      
DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
          
  EXEC AVL_InsertError 'GetEmployeeInfo', @ErrorMessage, @CustomerID, @EmployeeID       
END CATCH      
End
