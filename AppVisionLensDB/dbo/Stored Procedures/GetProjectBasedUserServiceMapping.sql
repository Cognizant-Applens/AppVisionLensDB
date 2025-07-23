/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



--exec GetProjectBasedUserServiceMapping '103404',7097
CREATE procedure [dbo].[GetProjectBasedUserServiceMapping](

@EmployeeID nvarchar(50), 
@CustomerID nvarchar(50)
)
as

begin

SET NOCOUNT ON;

declare @IsCognizant int 
declare @IsNonEsaMapAllowed int 
set @IsCognizant=(select IsCognizant from AVL.Customer where CustomerID=@CustomerID and IsDeleted=0)
set @IsNonEsaMapAllowed=(select IsNonESAMappingAllowed from AVL.Customer where CustomerID=@CustomerID and IsDeleted=0)
if(@IsCognizant=1) --and @IsNonEsaMapAllowed=1)
	BEGIN
	select distinct PM.ProjectID as ProjectID,
		PM.ProjectName as ProjectName,
		--case when ((select IsNonESAAuthorized from AVL.MAS_LoginMaster
		--where projectid=PM.ProjectID and EmployeeID=@EmployeeID and CustomerID=@CustomerID and IsDeleted=0)=0  
		--or(select IsNonESAAuthorized from AVL.MAS_LoginMaster
		--where projectid=PM.ProjectID and EmployeeID=@EmployeeID and CustomerID=@CustomerID and IsDeleted=0)is NULL)
		--then 0 else 1 end IsESAAllocated ,
		case when l.IsNonESAAuthorized =0 then 0 else l.IsNonESAAuthorized end as IsESAAllocated,
       STUFF((SELECT distinct ', ' + t1.ServiceLevelID
        from [AVL].[UserServiceLevelMapping] t1
		JOIN AVL.MAS_LoginMaster LMas on LMas.EmployeeID=@EmployeeID and LMas.IsDeleted=0
        where t1.EmployeeID = @EmployeeID
        and PM.ProjectID=t1.ProjectID and LMas.IsDeleted=0 
        FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') 
        ,1,2,'')  ServiceLevelID, L.EmployeeID
		--case when (select count(*) from AVL.MAS_LoginMaster where
		--projectid=PM.ProjectID and EmployeeID=l.EmployeeID and CustomerID=pm.CustomerID and L.IsDeleted=0)>0 
		--then   L.EmployeeID  else null end EmployeeID 
		into #AllProjects
		from  AVL.MAS_ProjectMaster PM 
		join AVL.MAS_LoginMaster L  on L.CustomerID=PM.CustomerID and L.EmployeeID=@EmployeeID and L.IsDeleted=0
		left join [AVL].[UserServiceLevelMapping] t on l.CustomerID=t.CustomerID and L.ProjectID=t.ProjectID and t.EmployeeID=@EmployeeID and L.IsDeleted=0
		where PM.CustomerID=@CustomerID and  L.Isdeleted=0 
		and L.EmployeeID=@EmployeeID and PM.IsDeleted=0

		update #AllProjects set IsESAAllocated=null 

		UPDATE ap set ap.IsESAAllocated= ISNULL(l.IsNonESAAuthorized,0)
		from #AllProjects ap
		join AVL.MAS_LoginMaster L on ap.EmployeeID=l.EmployeeID and ap.ProjectID=l.ProjectID and l.IsDeleted=0



		select distinct ProjectID,ProjectName,IsESAAllocated,ServiceLevelID,EmployeeID from #AllProjects

		drop TABLE #AllProjects

	END
else
	BEGIN
		select distinct L.ProjectID,PM.ProjectName,0 IsESAAllocated,
		STUFF((SELECT distinct ', ' + t1.ServiceLevelID
        from [AVL].[UserServiceLevelMapping] t1
        where t.EmployeeID = t1.EmployeeID
		and t.ProjectID=t1.ProjectID
        FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') 
        ,1,2,'') ServiceLevelID,
		L.EmployeeID
		from  avl.MAS_LoginMaster L
		join avl.MAS_ProjectMaster PM on PM.ProjectID=L.ProjectID
		left join [AVL].[UserServiceLevelMapping] t on L.ProjectID=t.ProjectID  and L.EmployeeID=t.EmployeeID
		where L.CustomerID=@CustomerID and   L.Isdeleted=0 and L.EmployeeID=@EmployeeID

	END
END





--select * from AVL.MAS_LoginMaster where employeeid=548986 and customerid=203










