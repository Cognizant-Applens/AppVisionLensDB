/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Insert_Update_Delete_AccessDetailsByUserID] @UserID VARCHAR(50)
	,@RoleName VARCHAR(max)
	,@BuID INT = NULL
	,@BuName VARCHAR(max) = NULL
	,@ProjectID INT = NULL
	,@ProjectName VARCHAR(max) = NULL
	,@CustomerID INT = NULL
	,@CustomerName VARCHAR(max) = NULL
	,@AccessLevel VARCHAR(max) = NULL
	,@CreatedUserID VARCHAR(50)
	,@ValidTillDate DATE = NULL
	,@Comments VARCHAR(max) = NULL
	,@IsActive INT
AS
BEGIN
	DECLARE @accesslevelsourceID INT
		,@RoleID INT
		,@Count INT

	--,@tilldate date                       
	IF (@AccessLevel = 'BU' or @AccessLevel = 'Horizontal')
	BEGIN
		--select * from [AVL].[UserRoleMapping] --where EmployeeID = 726051                       
		--select @tilldate=[Valid Till Date] from [AVL].[UserRoleMapping] where EmployeeID=@UserID and RoleID=@RoleID and AccessLevelSourceID = @accesslevelsourceID and AccessLevelID = @BuID                   
		SELECT @RoleID = RoleId
		FROM [AVL].[RoleMaster]
		WHERE RoleName = @RoleName

		SELECT @accesslevelsourceID = AccessLevelSourceID
		FROM [AVL].[AccessLevelSourceMaster]
		WHERE AccessLevel = @AccessLevel

		SELECT @Count = count(*)
		FROM [AVL].[UserRoleMapping]
		WHERE EmployeeID = @UserID
			AND RoleID = @RoleID
			AND AccessLevelSourceID = @accesslevelsourceID
			AND AccessLevelID = @BuID
			AND IsActive = 1

		IF (@Count = 0)
		BEGIN
			IF (@IsActive != 0)
			BEGIN
				INSERT INTO [AVL].[UserRoleMapping]
				VALUES (
					@UserID
					,@RoleID
					,@accesslevelsourceID
					,@BuID
					,1
					,@CreatedUserID
					,getdate()
					,@CreatedUserID
					,getdate()
					,'UI'
					,@ValidTillDate
					,@Comments
					)
			END

			DELETE
			FROM [AVL].[UserRoleMapping]
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @BuID
				AND IsActive = 0
		END
		ELSE
			UPDATE [AVL].[UserRoleMapping]
			SET [Valid Till Date] = @ValidTillDate
				,IsActive = @IsActive
				,ModifiedBy = @CreatedUserID
				,ModifiedDate = getdate()
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @BuID
				AND IsActive = 1
	END

	IF (@AccessLevel = 'Project')
	BEGIN
		--select @tilldate=[Valid Till Date] from [AVL].[UserRoleMapping] where  EmployeeID=@UserID and RoleID=@RoleID and AccessLevelSourceID = @accesslevelsourceID and AccessLevelID = @ProjectID                   
		SELECT @accesslevelsourceID = AccessLevelSourceID
		FROM [AVL].[AccessLevelSourceMaster]
		WHERE AccessLevel = @AccessLevel

		SELECT @RoleID = RoleId
		FROM [AVL].[RoleMaster]
		WHERE RoleName = @RoleName

		SELECT @Count = count(*)
		FROM [AVL].[UserRoleMapping]
		WHERE EmployeeID = @UserID
			AND RoleID = @RoleID
			AND AccessLevelSourceID = @accesslevelsourceID
			AND AccessLevelID = @ProjectID
			AND IsActive = 1

		IF (@Count = 0)
		BEGIN
			IF (@IsActive != 0)
			BEGIN
				INSERT INTO [AVL].[UserRoleMapping]
				VALUES (
					@UserID
					,@RoleID
					,@accesslevelsourceID
					,@ProjectID
					,1
					,@CreatedUserID
					,getdate()
					,@CreatedUserID
					,getdate()
					,'UI'
					,@ValidTillDate
					,@Comments
					)
			END

			DELETE
			FROM [AVL].[UserRoleMapping]
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @ProjectID
				AND IsActive = 0
		END
		ELSE
			UPDATE [AVL].[UserRoleMapping]
			SET [Valid Till Date] = @ValidTillDate
				,IsActive = @IsActive
				,ModifiedBy = @CreatedUserID
				,ModifiedDate = getdate()
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @ProjectID
				AND IsActive = 1
	END

	IF (@AccessLevel = 'Account')
	BEGIN
		--select @tilldate=[Valid Till Date] from [AVL].[UserRoleMapping] where EmployeeID=@UserID and RoleID=@RoleID and AccessLevelSourceID = @accesslevelsourceID and AccessLevelID = @CustomerID         
		SELECT @RoleID = RoleId
		FROM [AVL].[RoleMaster]
		WHERE RoleName = @RoleName

		SELECT @accesslevelsourceID = AccessLevelSourceID
		FROM [AVL].[AccessLevelSourceMaster]
		WHERE AccessLevel = @AccessLevel

		SELECT @Count = count(*)
		FROM [AVL].[UserRoleMapping]
		WHERE EmployeeID = @UserID
			AND RoleID = @RoleID
			AND AccessLevelSourceID = @accesslevelsourceID
			AND AccessLevelID = @CustomerID
			AND IsActive = 1

		IF (@Count = 0)
		BEGIN
			IF (@IsActive != 0)
			BEGIN
				INSERT INTO [AVL].[UserRoleMapping]
				VALUES (
					@UserID
					,@RoleID
					,@accesslevelsourceID
					,@CustomerID
					,1
					,@CreatedUserID
					,getdate()
					,@CreatedUserID
					,getdate()
					,'UI'
					,@ValidTillDate
					,@Comments
					)
			END

			DELETE
			FROM [AVL].[UserRoleMapping]
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @CustomerID
				AND IsActive = 0
		END
		ELSE
			UPDATE [AVL].[UserRoleMapping]
			SET [Valid Till Date] = @ValidTillDate
				,IsActive = @IsActive
				,ModifiedBy = @CreatedUserID
				,ModifiedDate = getdate()
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND AccessLevelID = @CustomerID
				AND IsActive = 1
	END

	IF (@AccessLevel = 'Admin')
	BEGIN
		SELECT @RoleID = RoleId
		FROM [AVL].[RoleMaster]
		WHERE RoleName = @RoleName

		SELECT @accesslevelsourceID = AccessLevelSourceID
		FROM [AVL].[AccessLevelSourceMaster]
		WHERE AccessLevel = @AccessLevel

		SELECT @Count = count(*)
		FROM [AVL].[UserRoleMapping]
		WHERE EmployeeID = @UserID
			AND RoleID = @RoleID
			AND AccessLevelSourceID = @accesslevelsourceID
			--and AccessLevelID = @BuID                 
			AND IsActive = 1

		IF (@Count = 0)
		BEGIN
			IF (@IsActive != 0)
			BEGIN
				INSERT INTO [AVL].[UserRoleMapping]
				VALUES (
					@UserID
					,@RoleID
					,@accesslevelsourceID
					,0
					,1
					,@CreatedUserID
					,getdate()
					,@CreatedUserID
					,getdate()
					,'UI'
					,@ValidTillDate
					,@Comments
					)
			END

			DELETE
			FROM [AVL].[UserRoleMapping]
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND IsActive = 0
		END
		ELSE
			UPDATE [AVL].[UserRoleMapping]
			SET [Valid Till Date] = @ValidTillDate
				,IsActive = @IsActive
				,ModifiedBy = @CreatedUserID
				,ModifiedDate = getdate()
			WHERE EmployeeID = @UserID
				AND RoleID = @RoleID
				AND AccessLevelSourceID = @accesslevelsourceID
				AND IsActive = 1
	END
END;
