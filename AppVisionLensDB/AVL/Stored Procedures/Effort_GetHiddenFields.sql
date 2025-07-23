/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[Effort_GetHiddenFields] 471741,110
CREATE Proc [AVL].[Effort_GetHiddenFields] 
@EmployeeID nvarchar(1000)=null
--@CustomerID BIGINT=NULL
AS
BEGIN
BEGIN TRY
select distinct 
ISNULL(LM.UserID,0) as UserID,
LM.ProjectID,
TZM.TZoneName AS UserTimeZone, 
case when Cust.Timezoneid is null then null
when Cust.Timezoneid is not null then (select TZoneName from AVL.MAS_TimeZoneMaster where Timezoneid= Cust.Timezoneid)  
end  as CustomerTimeZone,
PM.ProjectName

from AVL.MAS_LoginMaster LM
join AVL.MAS_ProjectMaster PM ON PM.ProjectID=LM.ProjectID
join AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
LEFT join AVL.RoleMaster RM on LM.RoleID=RM.RoleID
LEFT join AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID

left join  [AVL].[MAP_ProjectConfig] PC ON TZM.TimeZoneId=PC.TimeZoneID
where LM.EmployeeID=@EmployeeID and LM.IsDeleted=0 
--and LM.CustomerID=@CustomerID
--and RM.IsActive=1

select DISTINCT
cust.CustomerID as CustomerID,
Cust.CustomerName as CustomerName,
RTRIM(LTRIM(LM.EmployeeID)) as EmployeeID, 
Cust.IsEffortConfigured as IsEffortConfigured,
RTRIM(LTRIM(ISNULL(LM.EmployeeName,''))) as EmployeeName, 
Cust.IsCognizant as IsCognizant,
0 as IsDebtEngineEnabled,
Cust.IsDaily as IsDaily,
--TZM.HourDifference as HourDifference,
ISNULL(RM.RoleName,'') as RoleName,
case when Cust.IsEncryptionEnabled is null then 0
when Cust.IsEncryptionEnabled is not null then 1 
end  as IsEncryptionEnabled

from AVL.MAS_LoginMaster LM
join AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
LEFT join AVL.RoleMaster RM on LM.RoleID=RM.RoleID
LEFT join AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
where LM.EmployeeID=@EmployeeID and LM.IsDeleted=0 
--AND LM.CustomerID=@CustomerID
--and RM.IsActive=1
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetHiddenFields] ', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
