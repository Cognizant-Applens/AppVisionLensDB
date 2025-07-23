/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[RolePrivilegeMenus] 471741,44
CREATE proc [AVL].[RolePrivilegeMenus] --627134
@EmployeeID varchar(max)
--@CustomerId bigint
as
begin
BEGIN TRY

select PrivilegeID,MenuName from AVL.MAS_PrivilegeMaster where PrivilegeID=2 
UNION
select 4 as PrivilegeID,'TicketApprove/Unfreeze' as MenuName from AVL.MAS_LoginMaster where (HcmSupervisorID=@EmployeeID OR TSApproverID=@EmployeeID) 
--AND CustomerID=@CustomerId
UNION 
select 5 as PrivilegeID,'TicketUpload' as MenuName from AVL.MAS_LoginMaster where (HcmSupervisorID=@EmployeeID OR TSApproverID=@EmployeeID) 
--AND CustomerID=@CustomerId
UNION
select 2 as PrivilegeID,'TicketingModule' as MenuName from AVL.MAS_LoginMaster where (HcmSupervisorID=@EmployeeID OR TSApproverID=@EmployeeID) 
--AND CustomerID=@CustomerId
UNION
select 6 as PrivilegeID,'ErrorLog' as MenuName from AVL.MAS_LoginMaster where (HcmSupervisorID=@EmployeeID OR TSApproverID=@EmployeeID) 
--AND CustomerID=@CustomerId
UNION
select DISTINCT pm.PrivilegeID,pm.MenuName from AVL.MAS_RolePrivilegeMapping rpm
 join  AVL.MAS_PrivilegeMaster pm on rpm.PrivilegeID=pm.PrivilegeID
 join [AVL].[MAS_LoginMaster] lm on lm.roleid=rpm.RoleID where employeeid=@EmployeeID and lm.IsDeleted=0
and pm.PrivilegeID NOT IN(3,2,4,5,6)
 UNION
 --Conditional select for continuous learning review

 select DISTINCT pm.PrivilegeID,pm.MenuName from AVL.MAS_RolePrivilegeMapping rpm
 join  AVL.MAS_PrivilegeMaster pm on rpm.PrivilegeID=pm.PrivilegeID
 join [AVL].[MAS_LoginMaster] lm on lm.roleid=rpm.RoleID where employeeid=@EmployeeID and lm.IsDeleted=0
 AND pm.PrivilegeID=3 
 AND lm.ProjectID IN 
 (
SELECT
ProjectID
FROM
AVL.MAS_ProjectDebtDetails PDD
WHERE
PDD.IsAutoClassified='Y'
AND
PDD.IsMLSignOff=1
AND 
PDD.IsDeleted=0
)
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[RolePrevilageMenus] ', @ErrorMessage, @EmployeeID,0
		
	END CATCH  




END
