/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 
-- =============================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting Hierarchy details using customerID and userID
-- =============================================

-- exec [dbo].[GetHierarchyforSA_A_PA] '104559',7297,'AdminSuperAdmin'
 CREATE Proc [dbo].[GetHierarchyforSA_A_PA] 
 (
 @Employeid varchar(50),
 @CustomerId int,
 @Mode varchar(50)
 )
 AS
 BEGIN
 declare @isProxyAdmin int=0
 select @isProxyAdmin=count(1) from
			--AVL.EmployeeCustomerMapping ECM 
			--join AVL.EmployeeRoleMapping ERM on Erm.EmployeeCustomerMappingId=Ecm.Id
			[AVL].[VW_EmployeeCustomerProjectRoleBUMapping](NOLOCK) ecpm
 where ecpm.CustomerId=@CustomerId and ecpm.EmployeeId=@Employeid and ecpm.RoleId in (7)
 IF(@Mode='AdminSuperAdmin')
 BEGIN
  select DISTINCT C.CustomerID,C.CustomerName from 
  [AVL].[VW_EmployeeCustomerProjectRoleBUMapping](NOLOCK) ecpm
  --[AVL].[EmployeeCustomerMapping] LM
 ----Join [AVL].[MAS_ProjectMaster] PM on LM.CustomerID=PM.CustomerID
 Join [AVL].[Customer](NOLOCK) C on C.CustomerID=ecpm.CustomerID
 where ecpm.EmployeeID=@Employeid and ecpm.CustomerID=@CustomerId
 END

 IF(@Mode='ProxyAdmin')
 BEGIN
 if(@isProxyAdmin>0)
 Begin
	 select PM.CustomerID,C.CustomerName,PM.ProjectID,PM.ProjectName 
	 from 
	 [AVL].[VW_EmployeeCustomerProjectRoleBUMapping](NOLOCK) ecpm
	 --[AVL].[EmployeeCustomerMapping] LM
	 Join [AVL].[MAS_ProjectMaster](NOLOCK) PM on ecpm.CustomerID=PM.CustomerID and ecpm.ProjectID=pm.ProjectID
	 Join [AVL].[Customer](NOLOCK) C on C.CustomerID=PM.CustomerID
	 -- JOIN AVL.EmployeeCustomerMapping ECM on ECM.EmployeeId=@Employeid and ECM.CustomerId=C.CustomerID
	 -- JOIN AVL.EmployeeProjectMapping PMM on PMM.ProjectId=PM.ProjectID and ECM.Id=PMM.EmployeeCustomerMappingId
	 where ecpm.EmployeeID=@Employeid and ecpm.CustomerID=@CustomerId
 End
 ELSE
 Begin
	 select PM.CustomerID,C.CustomerName,PM.ProjectID,PM.ProjectName 
	 from 
	 [AVL].[VW_EmployeeCustomerProjectRoleBUMapping](NOLOCK) ecpm
	 -- [AVL].[EmployeeCustomerMapping] LM
	 Join [AVL].[MAS_ProjectMaster](NOLOCK) PM on ecpm.CustomerID=PM.CustomerID and ecpm.ProjectID=pm.ProjectID
	 Join [AVL].[Customer](NOLOCK) C on C.CustomerID=PM.CustomerID
	 where ecpm.EmployeeID=@Employeid and ecpm.CustomerID=@CustomerId
 End
 END

 END
