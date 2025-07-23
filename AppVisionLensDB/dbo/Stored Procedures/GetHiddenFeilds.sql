/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc [dbo].[GetHiddenFeilds] 
@UserId int=null
AS
BEGIN
begin try
select distinct 
ISNULL(LM.UserID,0) as UserID,
LM.ProjectID 
from AVL.MAS_LoginMaster LM
join AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
join AVL.RoleMaster RM on LM.RoleID=RM.RoleID
join AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
where LM.EmployeeID=@UserID and LM.IsDeleted=0 and RM.IsActive=1

select DISTINCT
LM.EmployeeID as EmployeeID,
ISNULL(LM.EmployeeName,'') as EmployeeName,
Cust.IsCognizant as IsCognizant,
Cust.IsDebtEngineEnabled as IsDebtEngineEnabled,
Cust.IsDaily as IsDaily,
Cust.IsCategoryConfigured as IsCategoryConfigured,
--TZM.HourDifference as HourDifference,
ISNULL(RM.RoleName,'') as RoleName
from AVL.MAS_LoginMaster LM
join AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
join AVL.RoleMaster RM on LM.RoleID=RM.RoleID
join AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
where LM.EmployeeID=@UserID and LM.IsDeleted=0 and RM.IsActive=1
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[GetHiddenFeilds] ', @ErrorMessage, @UserId,0
	END CATCH  
END


--select * from AVL.MAS_LoginMaster
