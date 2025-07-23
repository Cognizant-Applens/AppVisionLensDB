/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [GetTicketRoles] 37,35,587567
CREATE proc [dbo].[GetTicketRoles] --37,35,587567
(
@CustomerID int,
@ProjectID int,
@EmployeeID varchar(20)
)as
Begin
declare @userid varchar(20)
declare @isDataDictionary int=0
select @userid=userid from AVL.MAS_LoginMaster WHERE  CustomerID=@CustomerID and EmployeeID=@EmployeeID and isdeleted=0
IF EXISTS(select 1 from AVL.MAS_LoginMaster WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID ) AND CustomerID=@CustomerID and isdeleted=0 )
bEGIN


								SELECT @isDataDictionary=
										count(1) 
								FROM
										AVL.MAS_ProjectDebtDetails PDD
								WHERE
										PDD.IsDDAutoClassified='Y'
								and PDD.ProjectID in (select PDD.ProjectID from Avl.MAS_ProjectMaster  where CustomerID in(@CustomerID))
									
								AND (PDD.IsDeleted=0 or PDD.IsDeleted is NULL) 


if(@isDataDictionary>0)
Begin
sELECT 101 AS RoleId,'Lead' as RoleName
union ALL
sELECT 102 AS RoleId,'DataDictionary' as RoleName
END
else
BEGIN
sELECT 101 AS RoleId,'Lead' as RoleName
End
End
else
Begin
sELECT 100 AS RoleId,'Analyst' as RoleName
End
End
