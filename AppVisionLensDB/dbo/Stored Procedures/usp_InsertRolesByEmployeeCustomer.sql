/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC usp_InsertRolesByEmployeeCustomer '471742',7216,11489
--EXEC usp_InsertRolesByEmployeeCustomer '471742',8743,19255
--EXEC usp_InsertRolesByEmployeeCustomer '471742',7216,19986
--EXEC usp_InsertRolesByEmployeeCustomer '471742',8858,21328
--EXEC usp_InsertRolesByEmployeeCustomer '471742',37736,10478
--EXEC usp_InsertRolesByEmployeeCustomer '627384',8748,19083

CREATE PROC [dbo].[usp_InsertRolesByEmployeeCustomer]
(
	@EmployeeId varchar(50),
	@customerId BIGINT,
	@projectId BIGINT
)
AS
begin


declare @customemappindid int

BEGIN
BEGIN TRY
	if exists(select 1 from AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId)
	BEGIN
	SELECT 2
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId
	end
	ELSE
	Begin 
	SELECT 1
	insert into AVL.EmployeeCustomerMapping(EmployeeId,CustomerId,CreatedBy,CreatedOn)values(@EmployeeId,@customerId,@EmployeeId,getdate())
	select @customemappindid=Id from  AVL.EmployeeCustomerMapping where EmployeeId=@EmployeeId and CustomerId=@customerId
	End

	if not exists(select 1 from AVL.EmployeeRoleMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=6)
	BEGIN	
	insert into AVL.EmployeeRoleMapping(EmployeeCustomerMappingId,RoleId,CreatedBy,CreatedOn)values(@customemappindid,6,@EmployeeId,getdate())
	End

	if not EXISTS(select 1 from AVL.EmployeeProjectMapping where EmployeeCustomerMappingId=@customemappindid and ProjectId=@projectId)
	BEGIN
	insert into AVL.EmployeeProjectMapping(EmployeeCustomerMappingId,ProjectId,CreatedBy,CreatedOn)
	values(@customemappindid,@projectId,@EmployeeId,getdate())
	END
	if not EXISTS(select 1 from AVL.EmployeeScreenMapping where EmployeeCustomerMappingId=@customemappindid and RoleId=6)
	BEGIN
	insert into AVL.EmployeeScreenMapping(EmployeeCustomerMappingId,screenId, RoleId,AccessWrite,AccessRead)
    select @customemappindid,ScreenID,6,1,0 from AVL.ScreenMaster where IsActive=1


	END

END TRY
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'usp_CreateUserProject', @ErrorMessage, 0 ,@customerId
		
	END CATCH  
END
END
