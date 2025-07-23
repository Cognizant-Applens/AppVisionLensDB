/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[usp_UserAccess](
@EmployeeId varchar(max),
@CustomerName varchar(255),
@CustomerId int,
@ProjectName  varchar(255),
@ProjectId int,
@CreatedBy varchar(50),
@AdminType int
)

As 
Begin 

declare @txtcustomerId varchar(20)
declare @txtprojectId varchar(20)
declare @ErrorTable table(
description varchar(max),
Query varchar(max)

)


if Exists(select 1 from AVL.Customer where (CustomerName=@CustomerName or CustomerID=@CustomerId) and IsDeleted=0)
Begin
select @txtcustomerId=CustomerID from AVL.Customer where (CustomerName=@CustomerName or CustomerID=@CustomerId) and IsDeleted=0
End
ELSE
Begin
insert into @ErrorTable values('Provide the valid customer name/id','select CustomerID from AVL.Customer where CustomerName=@CustomerName')
End

if (@AdminType= 7 or @AdminType=3)
Begin
		if EXISTS(select 1 from AVL.MAS_ProjectMaster where (ProjectName=@ProjectName or ProjectID=@ProjectId) and IsDeleted=0 and CustomerID=@txtcustomerId)
			Begin 
			select @txtprojectId=ProjectID from AVL.MAS_ProjectMaster where (ProjectName=@ProjectName or ProjectID=@ProjectId) and IsDeleted=0 and CustomerID=@txtcustomerId
			End
			ELSE
			Begin
			insert into @ErrorTable values('Provide the valid project name/id','select ProjectID from AVL.MAS_ProjectMaster where ProjectName=@ProjectName')
			End
End

if not Exists(select 1 from AVL.MAS_LoginMaster where EmployeeID=@EmployeeId and IsDeleted=0)
Begin 
insert into @ErrorTable values('Provide the valid Employeeid','select * from AVL.MAS_LoginMaster where EmployeeID=@EmployeeId and IsDeleted=0')
END

declare @isuserManagementRole INT=1

if EXISTS(select * from @ErrorTable )
BEGIN
set @isuserManagementRole=0
select * from @ErrorTable
end

declare @customemappindid int

if @isuserManagementRole=1
BEGIN
	if exists(select 1 from AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@txtcustomerId)
	BEGIN
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@txtcustomerId
	end
	ELSE
	Begin 
	insert into AVL.EmployeeCustomerMapping(EmployeeId,CustomerId,CreatedBy,CreatedOn)values(@EmployeeId,@txtcustomerId,@createdBy,getdate())
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@txtcustomerId
	End

	if not exists(select 1 from AVL.EmployeeRoleMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=@AdminType)
	BEGIN	
	insert into AVL.EmployeeRoleMapping(EmployeeCustomerMappingId,RoleId,CreatedBy,CreatedOn)values(@customemappindid,@AdminType,@createdBy,getdate())
	End
	if (@AdminType=7 or @AdminType=3)
	Begin 
		if not EXISTS(select 1 from AVL.EmployeeProjectMapping where EmployeeCustomerMappingId=@customemappindid and ProjectId=@txtprojectId)
		BEGIN

			insert into AVL.EmployeeProjectMapping(EmployeeCustomerMappingId,ProjectId,CreatedBy,CreatedOn)
			values(@customemappindid,@txtprojectId,@createdBy,getdate())
		END
	END
	else 
	BEGIN
	  delete from  AVL.EmployeeProjectMapping where EmployeeCustomerMappingId=@customemappindid
	  insert into AVL.EmployeeProjectMapping(EmployeeCustomerMappingId,ProjectId,CreatedBy,CreatedOn)
	  select @customemappindid,ProjectID,@createdBy,getdate() from AVL.MAS_ProjectMaster where IsDeleted=0 and CustomerID=@txtcustomerId
	ENd
	if not EXISTS(select 1 from AVL.EmployeeScreenMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=@AdminType)
	BEGIN
	if (@AdminType=7 or @AdminType=1)
	Begin
	insert into AVL.EmployeeScreenMapping(EmployeeCustomerMappingId,screenId, RoleId,AccessWrite,AccessRead)
    select @customemappindid,ScreenID,@AdminType,1,0 from AVL.ScreenMaster where IsActive=1
	End
	END

End

--select ECM.EmployeeId,ECM.CustomerId,c.CustomerName,pm.ProjectName,SM.ScreenName,RM.RoleName from AVL.EmployeeCustomerMapping ECM join
--AVL.EmployeeProjectMapping EPM on ECM.Id=EPM.EmployeeCustomerMappingId
--join AVL.EmployeeRoleMapping ERM on ERM.EmployeeCustomerMappingId=ECM.Id
--join AVL.EmployeeScreenMapping ESM on ESM.EmployeeCustomerMappingId=ECM.Id
--JOIN AVL.ScreenMaster SM on SM.ScreenID=ESM.ScreenId
--join AVL.RoleMaster RM on RM.RoleId=ERM.RoleId
--join AVL.Customer C on C.CustomerID=ECM.CustomerId
--join AVL.MAS_ProjectMaster PM on PM.ProjectID=EPM.ProjectId
--where ECM.EmployeeId=@EmployeeId and C.CustomerID=@txtcustomerId

End



--select * from AVL.BusinessUnit
