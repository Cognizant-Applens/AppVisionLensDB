/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ExistingDataRoleUpdate]
AS
BEGIN
	DECLARE @Associate TABLE
	(
	AssociateID VARCHAR(100),
	ProjectID VARCHAR(50),
	AccountID VARCHAR(50)
	)	

	INSERT INTO @Associate
	SELECT DISTINCT AM.AssociateID AS AssociateID,PMA.ProjectID AS ProjectID,C.CustomerID AS AccountID
	FROM ESA.Associates AS AM
	INNER JOIN ESA.ProjectAssociates AS PAM ON PAM.AssociateID=AM.AssociateID
	INNER JOIN ESA.Projects AS PM ON PM.ID = PAM.ProjectID
	INNER join AVL.MAS_ProjectMaster as PMA on PMA.EsaProjectID = pm.ID
	INNER JOIN AVL.Customer AS C ON C.ESA_AccountID = PM.AccountID AND C.IsDeleted = 0
	where AM.IsActive = 1  

	-----PROJECT MANAGER
		IF EXISTS(select * from sys.objects where type = 'U' AND name = 'EXISTINGEMPLOYEEIDS')
		BEGIN
				DROP table EXISTINGEMPLOYEEIDS 
		END
		CREATE TABLE EXISTINGEMPLOYEEIDS 
		(
			EMPLOYEEID VARCHAR(50),
			CUSTOMERID VARCHAR(50) 
		)

		INSERT INTO EXISTINGEMPLOYEEIDS
		Select distinct A.AssociateID,a.AccountID from @Associate A  
		INTERSECT 
		Select b.EmployeeId,b.customerID from AVL.EmployeeCustomerMapping B

		IF EXISTS(select * from sys.objects where type = 'U' AND name = 'Temp_PMAssociate')
		BEGIN
				DROP table Temp_PMAssociate 
		END
		CREATE table Temp_PMAssociate 
			(
				AssociateID VARCHAR(100),
				ProjectID VARCHAR(50),
				AccountID VARCHAR(50),
				EsaProjectID VARCHAR(50),
				ProjectManagerID varchar(50),
				AccountManagerID VARCHAR(50)
			)

		INSERT into Temp_PMAssociate
		SELECT DISTINCT AM.EMPLOYEEID AS AssociateID,PMA.ProjectID AS ProjectID,C.CustomerID AS AccountID,
		PMA.EsaProjectID,PM.ProjectManagerID,pm.AccountManagerID FROM EXISTINGEMPLOYEEIDS AS AM
		INNER JOIN ESA.ProjectAssociates AS PAM ON PAM.AssociateID=AM.EMPLOYEEID
		INNER JOIN ESA.Projects AS PM ON PM.ID = PAM.ProjectID
		INNER join AVL.MAS_ProjectMaster as PMA on PMA.EsaProjectID = pm.ID
		INNER JOIN AVL.Customer AS C ON C.ESA_AccountID = PM.AccountID AND C.IsDeleted = 0

		declare @PM TABLE
		(
			EmployeeCustomerMappingId varchar(50),
			RoleID varchar(10),
			EmployeeId varchar(10)
		)

		INSERT into @PM
		SELECT distinct D.EmployeeCustomerMappingId,D.RoleID,B.EmployeeId FROM Temp_PMAssociate A
		INNER JOIN AVL.EmployeeCustomerMapping(NOLOCK) B ON A.ProjectManagerID = B.EmployeeId and A.AccountID = b.CustomerId
		INNER join AVL.EmployeeProjectMapping(NOLOCK) C on c.EmployeeCustomerMappingId = b.Id and c.ProjectId = a.ProjectID
		inner join AVL.EmployeeRoleMapping(NOLOCK) D on D.EmployeeCustomerMappingId = b.Id 

		INSERT INTO AVL.EmployeeRoleMapping
		Select EmployeeCustomerMappingId,6,'System-PM-AM',GETDATE(),NULL,NULL from @PM where EmployeeId  NOT IN (SELECT EmployeeId FROM @PM WHERE ROLEID IN ('6'))

	------ENGAGEMENT LEVEL

		declare @EL TABLE
		(
			EmployeeCustomerMappingId varchar(50),
			RoleID varchar(10),
			EmployeeId varchar(10)
		)

		INSERT into @EL
		SELECT distinct D.EmployeeCustomerMappingId,D.RoleID,B.EmployeeId FROM Temp_PMAssociate A
		INNER JOIN AVL.EmployeeCustomerMapping B ON A.AccountManagerID = B.EmployeeId and A.AccountID = b.CustomerId
		INNER join AVL.EmployeeProjectMapping C on c.EmployeeCustomerMappingId = b.Id and c.ProjectId = a.ProjectID
		inner join AVL.EmployeeRoleMapping D on D.EmployeeCustomerMappingId = b.Id 
	

		INSERT INTO AVL.EmployeeRoleMapping
		Select EmployeeCustomerMappingId,1,'System-PM-AM',GETDATE(),NULL,NULL from @EL where EmployeeId  NOT IN (SELECT EmployeeId FROM @EL WHERE ROLEID IN ('1'))

END
