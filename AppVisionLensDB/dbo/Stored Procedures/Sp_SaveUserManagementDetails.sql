/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Sp_SaveUserManagementDetails](
 @employeeid VARCHAR(50),
 @employeename VARCHAR(50),
 @emailid VARCHAR(255),
 @CustomerId bigint,
 @role VARCHAR(8000),
 @appname VARCHAR(8000),
 @screenroles TVP_ScreenAccess readonly,
 @employeecustomerproject TVP_EmployeeCustomerProject readonly,
 @createdby varchar(50)
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	DECLARE @ID INT;
	DECLARE @COUNT INT;
	DECLARE @INDX INT;
	DECLARE @i INT;
	DECLARE @single_role NVARCHAR(100);
	DECLARE @single_role_name NVARCHAR(100);
	DECLARE @temprole NVARCHAR(4000);
 
	DECLARE @tempapp NVARCHAR(4000);
 
	DECLARE @ClusterId BIGINT;
SET @i = 0;
SET @INDX = 1;

--INSERT INTO AVL.UserDetails(UserId,UserName,EmailID)
--VALUES(@employeeid,@employeename,@emailid);

IF EXISTS (SELECT
		1
	FROM [AVL].[EmployeeCustomerMapping]
	WHERE EmployeeID = @employeeid
	AND CustomerID = @CustomerId) BEGIN

UPDATE AVL.MAS_LoginMaster
SET	EmployeeName = @employeename
	,EmployeeEmail = @emailid
WHERE EmployeeID = @employeeid
AND CustomerID = @CustomerId

UPDATE [AVL].[EmployeeCustomerMapping]
SET	ModifiedBy = @createdby
	,ModifiedOn = GETDATE()
WHERE EmployeeID = @employeeid
AND CustomerID = @CustomerId

SET @ID = (SELECT
		Id
	FROM [AVL].[EmployeeCustomerMapping]
	WHERE EmployeeID = @employeeid
	AND CustomerID = @CustomerId)

END ELSE BEGIN

INSERT INTO [AVL].[EmployeeCustomerMapping] (EmployeeID, CustomerID, CreatedBy, createdOn)
	VALUES (@employeeid, @CustomerId, @createdby, GETDATE());
SET @ID = @@IDENTITY;
END

DECLARE @role_results AS TABLE(rolename VARCHAR(100));

WHILE @INDX != 0 BEGIN
-- GET THE INDEX OF THE FIRST OCCURENCE OF THE SPLIT CHARACTER

SET @INDX = CHARINDEX(',', @role);
-- NOW PUSH EVERYTHING TO THE LEFT OF IT INTO THE SLICE VARIABLE
IF @INDX != 0 BEGIN
SET @temprole = LEFT(@role, @INDX - 1);
END ELSE BEGIN
SET @temprole = @role;
END;
-- PUT THE ITEM INTO THE RESULTS SET
INSERT INTO @role_results (rolename)
	VALUES (@temprole);
-- CHOP THE ITEM REMOVED OFF THE MAIN STRING
SET @role = RIGHT(@role, LEN(@role) - @INDX);
-- BREAK OUT IF WE ARE DONE
IF LEN(@role) = 0 BEGIN
BREAK;
END;
END;


SET @INDX = 1;

DECLARE @app_results AS TABLE(application_name VARCHAR(100));

MyLoop:
WHILE @INDX != 0 BEGIN
-- GET THE INDEX OF THE FIRST OCCURENCE OF THE SPLIT CHARACTER
SET @INDX = CHARINDEX(',', @appname);

-- NOW PUSH EVERYTHING TO THE LEFT OF IT INTO THE SLICE VARIABLE
IF @INDX != 0 BEGIN
SET @tempapp = LEFT(@appname, @INDX - 1);
END ELSE BEGIN
SET @tempapp = @appname;
END;
-- PUT THE ITEM INTO THE RESULTS SET
INSERT INTO @app_results (application_name)
	VALUES (@tempapp);

-- CHOP THE ITEM REMOVED OFF THE MAIN STRING
SET @appname = RIGHT(@appname, LEN(@appname) - @INDX);
-- BREAK OUT IF WE ARE DONE
IF LEN(@appname) = 0 BEGIN
BREAK;
END;
END;

--SELECT application_name FROM @app_results;
SET @count = (SELECT
		COUNT(*)
	FROM @role_results);
DELETE FROM [AVL].[EmployeeRoleMapping]
WHERE EmployeeCustomerMappingId = @ID

WHILE (@i < @count) BEGIN
SET @single_role = (SELECT TOP 1
		[RoleId]
	FROM @role_results A
	INNER JOIN [AVL].[RoleMaster] B
		ON B.RoleName = A.rolename
	ORDER BY A.rolename);
SET @single_role_name = (SELECT TOP 1
		B.RoleName
	FROM @role_results A
	INNER JOIN [AVL].[RoleMaster] B
		ON B.RoleName = A.rolename
	ORDER BY A.rolename);


INSERT INTO [AVL].[EmployeeRoleMapping] (EmployeeCustomerMappingId, RoleID, CreatedBy, CreatedOn)
	VALUES (@ID, @single_role, @createdby, GETDATE());
SET @i = @i + 1;

DELETE FROM @role_results
WHERE rolename = @single_role_name;
END;

SET @i = 0;

SET @count = (SELECT
		COUNT(*)
	FROM @app_results);



DELETE FROM [AVL].[EmployeeSubClusterMapping]
WHERE EmployeeCustomerMappingId = @ID

WHILE (@i < @count) BEGIN
SET @single_role = (SELECT TOP 1
		application_name
	FROM @app_results
	ORDER BY application_name);
PRINT @single_role;
SET @ClusterId = (SELECT TOP 1
		BusinessClusterMapID
	FROM AVL.BusinessClusterMapping
	WHERE CustomerId = @CustomerId
	AND IsHavingSubBusinesss=0
	AND BusinessClusterBaseName = LTRIM(RTRIM(@single_role)));
PRINT @ClusterId



--   INSERT into AVL.APP_MAP_SubClusterUserMapping
--(UserID,CustomerId,SubClusterID,[IsDeleted],CreatedBy,CreatedDate)
--SELECT
--@ID,@CustomerId,[BusinessClusterMapID],0,471741,GETDATE() from AVL.BusinessClusterMapping
--where CustomerID=@CustomerId and BusinessClusterBaseName=@single_role;
--PRINT @ClusterId
IF (@appname != '' and @ClusterId IS NOT NULL ) BEGIN
INSERT INTO [AVL].[EmployeeSubClusterMapping] (EmployeeCustomerMappingId, SubClusterID, CreatedBy, CreatedOn)
	VALUES (@ID, @ClusterId, @createdby, GETDATE())
END
SET @i = @i + 1;

DELETE FROM @app_results
WHERE application_name = @single_role;
END;

DELETE FROM [AVL].[EmployeeScreenMapping]
WHERE EmployeeCustomerMappingId = @ID

INSERT INTO [AVL].[EmployeeScreenMapping] (EmployeeCustomerMappingId, RoleId, ScreenId, AccessRead, AccessWrite)
	SELECT
		@ID
		,B.RoleID
		,ScreenID
		,[Read]
		,Write
	FROM @screenRoles A
	INNER JOIN [AVL].[RoleMaster] B
		ON B.RoleName = A.rolename
		AND ScreenId IS NOT NULL
		AND B.RoleId NOT IN (2, 3, 8, 4, 5)

IF EXISTS (SELECT
		1
	FROM @employeecustomerproject
	WHERE RoleName NOT IN ('SuperAdmin', 'Admin')) BEGIN
DELETE FROM [AVL].[EmployeeProjectMapping]
WHERE EmployeeCustomerMappingId = @ID
INSERT INTO [AVL].[EmployeeProjectMapping] (EmployeeCustomerMappingId, ProjectId, CreatedBy, CreatedOn)
	SELECT
		@ID
		,PM.ProjectId
		,@createdby
		,GETDATE()
	FROM @employeecustomerproject ECP
	JOIN [AVL].[MAS_ProjectMaster] PM
		ON PM.ProjectName = ECP.ProjectName
		AND Pm.CustomerID = @CustomerId
END
IF EXISTS (SELECT
		1
	FROM @employeecustomerproject
	WHERE RoleName IN ('Admin')
	AND RoleName NOT IN ('Proxy Admin')) BEGIN
DELETE FROM [AVL].[EmployeeProjectMapping]
WHERE EmployeeCustomerMappingId = @ID
INSERT INTO [AVL].[EmployeeProjectMapping] (EmployeeCustomerMappingId, ProjectId, CreatedBy, CreatedOn)
	SELECT
		@ID
		,PM.ProjectId
		,@createdby
		,GETDATE()
	FROM [AVL].[MAS_ProjectMaster] PM
	WHERE PM.CustomerID = @CustomerId
	AND PM.IsDeleted = 0
END


COMMIT TRAN
END TRY BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

--INSERT Error    
EXEC AVL_InsertError	'[dbo].[Sp_SaveUserManagementDetails] ' 
						,@ErrorMessage
						,0
						,@CustomerId
ROLLBACK TRAN
END CATCH
END
