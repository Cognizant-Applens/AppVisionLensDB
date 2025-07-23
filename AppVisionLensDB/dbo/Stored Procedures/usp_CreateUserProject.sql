/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--usp_CreateUserProject 'Cust_Viji','Project_Viji','viji ','215573','viji@cognizant.com',0,'587567',1
CREATE proc [dbo].[usp_CreateUserProject](
@CustomerName varchar(255),
@ProjectName  varchar(255),
@EmployeeName varchar(255),
@EmployeeId varchar(50),
@EmployeeEmailId varchar(255),
@IsCognizant bit,
@createdBy varchar(50),
@isuserManagementRole bit
)

As 
Begin 

declare @customerId varchar(20)
declare @projectId varchar(20)



if Exists(select 1 from AVL.Customer where CustomerName=@CustomerName and IsDeleted=0)
Begin
select @customerId=CustomerID from AVL.Customer where CustomerName=@CustomerName and IsDeleted=0
End
ELSE
Begin
INSERT into AVL.Customer(CustomerName,BUID,CreatedBy,CreatedDate,IsCognizant,IsDeleted) values(@CustomerName,1,@createdBy,getdate(),@IsCognizant,0)
select @customerId=CustomerID from AVL.Customer where CustomerName=@CustomerName and IsDeleted=0
End

if EXISTS(select 1 from AVL.MAS_ProjectMaster where ProjectName=@ProjectName and IsDeleted=0 and CustomerID=@customerId)
Begin 
select @projectId=ProjectID from AVL.MAS_ProjectMaster where ProjectName=@ProjectName and IsDeleted=0 and CustomerID=@customerId
End
ELSE
Begin
INSERT into AVL.MAS_ProjectMaster(ProjectName,CustomerID,CreatedBY,IsDeleted,CreateDate,EsaProjectID,IsESAProject)values(@ProjectName,@customerId,@createdBy,0,getdate(),0,1)
select @projectId=ProjectID from AVL.MAS_ProjectMaster where ProjectName=@ProjectName and IsDeleted=0 and CustomerID=@customerId
End
if not Exists(select 1 from AVL.MAS_LoginMaster where EmployeeID=@EmployeeId and IsDeleted=0)
Begin 
insert into AVL.MAS_LoginMaster(EmployeeID,EmployeeName,EmployeeEmail,ProjectID,CustomerID, IsDeleted,RoleID,CreatedBy,CreatedDate,ClientUserID,HcmSupervisorID,TSApproverID)
VALUES(@EmployeeId,@EmployeeName,@EmployeeEmailId,@projectId,@customerId,0,1,@createdBy,getdate(),@EmployeeId,@EmployeeId,@EmployeeId)
END




declare @customemappindid int

if @isuserManagementRole=1
BEGIN
	if exists(select 1 from AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId)
	BEGIN
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId
	end
	ELSE
	Begin 
	insert into AVL.EmployeeCustomerMapping(EmployeeId,CustomerId,CreatedBy,CreatedOn)values(@EmployeeId,@customerId,@createdBy,getdate())
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId
	End

	if not exists(select 1 from AVL.EmployeeRoleMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=1)
	BEGIN	
	insert into AVL.EmployeeRoleMapping(EmployeeCustomerMappingId,RoleId,CreatedBy,CreatedOn)values(@customemappindid,1,@createdBy,getdate())
	End

	if not EXISTS(select 1 from AVL.EmployeeProjectMapping where EmployeeCustomerMappingId=@customemappindid and ProjectId=@projectId)
	BEGIN
	insert into AVL.EmployeeProjectMapping(EmployeeCustomerMappingId,ProjectId,CreatedBy,CreatedOn)
	values(@customemappindid,@projectId,@createdBy,getdate())
	END
	if not EXISTS(select 1 from AVL.EmployeeScreenMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=1)
	BEGIN
	insert into AVL.EmployeeScreenMapping(EmployeeCustomerMappingId,screenId, RoleId,AccessWrite,AccessRead)
    select @customemappindid,ScreenID,1,1,0 from AVL.ScreenMaster where IsActive=1

	END

End

select ECM.EmployeeId,ECM.CustomerId,c.CustomerName,pm.ProjectName,SM.ScreenName,RM.RoleName from AVL.EmployeeCustomerMapping ECM join
AVL.EmployeeProjectMapping EPM on ECM.Id=EPM.EmployeeCustomerMappingId
join AVL.EmployeeRoleMapping ERM on ERM.EmployeeCustomerMappingId=ECM.Id
join AVL.EmployeeScreenMapping ESM on ESM.EmployeeCustomerMappingId=ECM.Id
JOIN AVL.ScreenMaster SM on SM.ScreenID=ESM.ScreenId
join AVL.RoleMaster RM on RM.RoleId=ERM.RoleId
join AVL.Customer C on C.CustomerID=ECM.CustomerId
join AVL.MAS_ProjectMaster PM on PM.ProjectID=EPM.ProjectId
where ECM.EmployeeId=@EmployeeId and C.CustomerID=@customerId

End



--select * from AVL.BusinessUnit
