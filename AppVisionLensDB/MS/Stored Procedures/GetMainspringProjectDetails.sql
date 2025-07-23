/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [MS].[GetMainspringProjectDetails]
(
@EmployeeID varchar(50),
@CustomerID varchar(50)
)
as
begin
SET NOCOUNT ON;
--select ProjectID,ProjectName,IsMainSpringConfigured from AVL.MAS_ProjectMaster 
-- where IsDeleted=0 
-- and IsMainSpringConfigured='Y'
--new sp
 select * into #assignedProjects from avl.MAS_LoginMaster(NOLOCK) where EmployeeID=@EmployeeID and IsDeleted=0 and CustomerID=@CustomerID

select * into #SupervisedProjects from avl.MAS_LoginMaster(NOLOCK) where HcmSupervisorID=@EmployeeID and IsDeleted=0 and CustomerID=@CustomerID

CREATE TABLE #ProjectIDList
(
ProjectID INT
)

Insert into #ProjectIDList
select ProjectID from #assignedProjects WITH(NOLOCK)
UNION
select ProjectID from #SupervisedProjects WITH(NOLOCK)
SELECT  pl.ProjectID,CONCAT(pm.EsaProjectID, '-', pm.ProjectName) AS ProjectName, ISNULL(pm.IsODCRestricted,'N') AS IsODCRestricted
from avl.MAS_ProjectMaster(NOLOCK) pm join #ProjectIDList pl WITH(NOLOCK) ON pm.ProjectID=pl.ProjectID   
--select pl.ProjectID,pm.ProjectName,ISNULL(pm.IsODCRestricted,'N') AS IsODCRestricted
--from avl.MAS_ProjectMaster(NOLOCK) pm join #ProjectIDList pl on pm.ProjectID=pl.ProjectID  
drop table #ProjectIDList
SET NOCOUNT OFF;
end
