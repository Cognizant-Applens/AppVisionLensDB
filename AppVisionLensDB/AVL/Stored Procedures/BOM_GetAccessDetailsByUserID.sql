/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[BOM_GetAccessDetailsByUserID] @UserID NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		DECLARE @ProjID VARCHAR(50) = NULL
		DECLARE @ProjName VARCHAR(50) = NULL
		DECLARE @CustomerID BIGINT = NULL
		DECLARE @ESACustomerID BIGINT = NULL
		DECLARE @CustomerName VARCHAR(50) = NULL
		DECLARE @BUID VARCHAR(50) = NULL
		DECLARE @BUName VARCHAR(50) = NULL
		DECLARE @ESAAccountID VARCHAR(50) = NULL
		DECLARE @UseParent INT = NULL
		DECLARE @ParentCustomerID VARCHAR(50) = NULL
		DECLARE @ParentCustomerName VARCHAR(50) = NULL

		CREATE TABLE #tempSource (
			RoleId [int] NOT NULL
			,RoleName NVARCHAR(100) NOT NULL
			,AccessLevel NVARCHAR(50) NOT NULL
			,EmployeeID NVARCHAR(50) NOT NULL
			,ProjectID [int] NULL
			,ProjectName VARCHAR(200) NULL
			,CustomerID [int] NULL
			,CustomerName VARCHAR(200) NULL
			,ESACustomerID [int] NULL
			,BUID [int] NULL
			,BUName [varchar](200) NULL
			,UseParent [int] NULL
			,ParentCustomerID [int] NULL
			,ParentCustomerName [varchar](200) NULL
			,UserRoleMappingID [int] NULL
			)

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,cus.CustomerID
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerName
				ELSE cus.CustomerName
				END AS CustomerName
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerID
				ELSE cus.ESA_AccountID
				END AS ESACustomerID
			,bu.BUID AS BUID
			,bu.BUName AS BUName
			,trn.UseParent AS UseParent
			,trn.parentID AS ParentCustomerID
			,parent.parentcustomerName AS ParentCustomerName
			,URM.UserRoleMappingID
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].[Customer] cus(NOLOCK) ON urm.AccessLevelID = cus.CustomerID
		JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON cus.BUID = bu.BUID
		LEFT JOIN [ESA].[BUParentAccounts] parent(NOLOCK) ON cus.customerid = parent.customerid
		LEFT JOIN [BusinessOutcome].[trn].[accountlistmapping] trn(NOLOCK) ON trn.parentid = parent.parentcustomerid
		LEFT JOIN [AVL].[MAS_ProjectMaster] pm ON cus.CustomerID = pm.CustomerID
		--JOIN [AVL].[PRJ_ConfigurationProgress] pcp ON pm.ProjectID = pcp.ProjectID
		--	AND pcp.ScreenID = 2
		--	AND pcp.ITSMScreenID = 11
		--	AND pcp.CompletionPercentage = 100
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Account'
			AND urm.EmployeeID = @UserID
			AND cus.IsCognizant = 1

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,parent.CustomerID AS CustomerID
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerName
				ELSE cus.CustomerName
				END AS CustomerName
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerID
				ELSE cus.ESA_AccountID
				END AS ESACustomerID
			,bu.BUID
			,bu.BUName
			,trn.UseParent AS UseParent
			,trn.parentID AS ParentCustomerID
			,parent.parentcustomerName AS ParentCustomerName
			,URM.UserRoleMappingID
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON urm.AccessLevelID = bu.BUID
		LEFT JOIN [BusinessOutcome].[TRN].[Accountlistmapping] trn(NOLOCK) ON urm.UserRoleMappingId = trn.USerRoleMappingID
		LEFT JOIN [ESA].[BUParentAccounts] parent(NOLOCK) ON trn.parentid = parent.parentcustomerid
		LEFT JOIN [AVL].[Customer] cus ON bu.BUID = cus.BUID
		LEFT JOIN [AVL].[MAS_ProjectMaster] pm ON cus.CustomerID = pm.CustomerID
		--JOIN [AVL].[PRJ_ConfigurationProgress] pcp ON pm.ProjectID = pcp.ProjectID
		--	AND pcp.ScreenID = 2
		--	AND pcp.ITSMScreenID = 11
		--	AND pcp.CompletionPercentage = 100
		WHERE urm.IsActive = 1
			AND (
				alsm.AccessLevel = 'BU'
				OR alsm.AccessLevel = 'Sub Horizontal'
				)
			AND urm.EmployeeID = @UserID
			AND cus.IsCognizant = 1
		ORDER BY bu.BUID DESC

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,pm.ProjectID AS ProjectID
			,pm.ProjectName AS ProjectName
			,cus.CustomerID
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerName
				ELSE cus.CustomerName
				END AS CustomerName
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerID
				ELSE cus.ESA_AccountID
				END AS ESACustomerID
			,bu.BUID
			,bu.BUName
			,trn.UseParent AS UseParent
			,trn.parentID AS ParentCustomerID
			,parent.parentcustomerName AS ParentCustomerName
			,URM.UserRoleMappingID
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].MAS_ProjectMaster pm(NOLOCK) ON urm.AccessLevelID = pm.ProjectID
		JOIN [AVL].[Customer] cus(NOLOCK) ON pm.CustomerID = cus.CustomerID
		JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON cus.BUID = bu.BUID
		LEFT JOIN [ESA].[BUParentAccounts] parent(NOLOCK) ON cus.customerid = parent.customerid
		LEFT JOIN [BusinessOutcome].[trn].[accountlistmapping] trn(NOLOCK) ON trn.parentid = parent.parentcustomerid
		--JOIN [AVL].[PRJ_ConfigurationProgress] pcp ON pm.ProjectID = pcp.ProjectID
		--	AND pcp.ScreenID = 2
		--	AND pcp.ITSMScreenID = 11
		--	AND pcp.CompletionPercentage = 100
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Project'
			AND bu.BUName NOT IN ('INTERNAL')
			AND urm.EmployeeID = @UserID
			AND cus.IsCognizant = 1

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,@CustomerID AS CustomerID
			,@CustomerName AS CustomerName
			,@ESACustomerID AS ESACustomerID
			,bu.BUID AS BUID
			,bu.BUName AS BUName
			,trn.UseParent AS UseParent
			,trn.parentID AS ParentCustomerID
			,parent.parentcustomerName AS ParentCustomerName
			,URM.UserRoleMappingID
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		LEFT JOIN [BusinessOutcome].[TRN].[Accountlistmapping] trn(NOLOCK) ON urm.UserRoleMappingId = trn.USerRoleMappingID
		LEFT JOIN [ESA].[BUParentAccounts] parent(NOLOCK) ON trn.parentid = parent.parentcustomerid
		LEFT JOIN [AVL].[MAS_ProjectMaster] pm ON parent.CustomerID = pm.CustomerID
		--JOIN [AVL].[PRJ_ConfigurationProgress] pcp ON pm.ProjectID = pcp.ProjectID
		--	AND pcp.ScreenID = 2
		--	AND pcp.ITSMScreenID = 11
		--	AND pcp.CompletionPercentage = 100
			,[AVL].[BusinessUnit] bu(NOLOCK)
		WHERE alsm.AccessLevel = 'Horizontal'
			AND urm.IsActive = 1
			AND bu.IsHorizontal = 'N'
			AND bu.BUName != 'AVM'
			AND urm.EmployeeID = @UserID

		DECLARE @RoleID INT
			,@Rolename NVARCHAR(100)
			,@AccessLevelSourceID INT
			,@AccessLevel NVARCHAR(50)
			,@UserRoleMappingID INT
			,@BUId_BVA INT
			,@BUName_BVA VARCHAR(50)
			,@CustomerID_BVA BIGINT = NULL
			,@ESACustomerID_BVA BIGINT = NULL
			,@CustomerName_BVA VARCHAR(50) = NULL
			,@Count INT = 0

		SELECT @RoleID = RoleId
			,@Rolename = RoleName
		FROM avl.RoleMaster
		WHERE RoleId = 12

		SELECT @AccessLevelSourceID = AccessLevelSourceID
			,@AccessLevel = AccessLevel
		FROM avl.AccessLevelSourceMaster
		WHERE AccessLevelSourceID = 6

		SELECT @UserRoleMappingID = UserRoleMappingID
		FROM avl.userrolemapping
		WHERE EmployeeID = @UserID
			AND RoleID = @RoleID

		SELECT @Count = count(*)
		FROM avl.userrolemapping urm
		INNER JOIN avl.RoleMaster rm ON rm.RoleId = urm.RoleID
		WHERE urm.EmployeeID = @UserID
			AND urm.IsActive = 1
			AND rm.RoleId = @RoleID

		SELECT DISTINCT bu.BUId
			,BUName
			,cus.CustomerID
			,trn.UseParent
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerName
				ELSE cus.CustomerName
				END AS CustomerName
			,CASE 
				WHEN trn.UseParent = 1
					THEN parent.ParentCustomerID
				ELSE cus.ESA_AccountID
				END AS ESACustomerID
		INTO #tempBU_BVA
		FROM [ESA].[BUParentAccounts] parent
		JOIN [BusinessOutcome].[TRN].[Accountlistmapping] trn ON trn.parentid = parent.parentcustomerid
		JOIN [AVL].[Customer] cus ON trn.AccountId = cus.CustomerID
		JOIN [AVL].[BusinessUnit] bu ON bu.BUID = cus.BUID
		LEFT JOIN [AVL].[MAS_ProjectMaster] pm ON cus.CustomerID = pm.CustomerID
		--JOIN [AVL].[PRJ_ConfigurationProgress] pcp ON pm.ProjectID = pcp.ProjectID
		--	AND pcp.ScreenID = 2
		--	AND pcp.ITSMScreenID = 11
		--	AND pcp.CompletionPercentage = 100
		WHERE bu.isdeleted = 0
			AND IsHorizontal = 'N'
			AND BUName NOT IN ('INTERNAL')
			AND bu.BUID NOT IN (
				4
				,6
				,5
				,8
				,10
				,15
				,18
				,19
				)
			AND cus.IsCognizant = 1
		ORDER BY bu.BUName DESC

		IF (@Count > 0)
			WHILE EXISTS (
					SELECT *
					FROM #tempBU_BVA
					)
			BEGIN
				SELECT @BUId_BVA = BUId 
				        ,@CustomerID_BVA = CustomerID
					,@CustomerName_BVA = CustomerName
					,@ESACustomerID_BVA = ESACustomerID
					,@BUName_BVA = BUName
				FROM #tempBU_BVA
				ORDER BY BUId ASC

				INSERT INTO #tempSource
				VALUES (
					@RoleID
					,@Rolename
					,@AccessLevel
					,@UserID
					,NULL
					,NULL
					,@CustomerID_BVA
					,@CustomerName_BVA
					,@ESACustomerID_BVA
					,@BUId_BVA
					,@BUName_BVA
					,NULL
					,NULL
					,NULL
					,@UserRoleMappingID
					)

				DELETE #tempBU_BVA
				WHERE BUId = @BUId_BVA
			END

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,acm.AccessLevel
			,urm.EmployeeID
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,@CustomerID AS CustomerID
			,@CustomerName AS CustomerName
			,@ESAAccountID AS ESAAccountID
			,@BUID AS BUID
			,@BUName AS BUName
			,@UseParent AS UseParent
			,@ParentCustomerID AS ParentCustomerID
			,@ParentCustomerName AS ParentCustomerName
			,@UserRoleMappingID AS UserRoleMappingID
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelMapping] acm(NOLOCK) ON rm.RoleName = acm.RoleName
		WHERE urm.IsActive = 1
			AND acm.AccessLevel NOT IN (
				'Project'
				,'Account'
				,'BU'
				)
			AND urm.EmployeeID = @UserID

		SELECT DISTINCT RoleId
			,RoleName
			,AccessLevel
			,ProjectID
			,ProjectName
			,CustomerID
			,CustomerName
			,ESACustomerID
			,BUID
			,BUName
			,UseParent
			,ParentCustomerID
			,ParentCustomerName
			,UserRoleMappingID
		FROM #tempSource
		WHERE EmployeeID = @UserID
			AND BUName NOT IN ('INTERNAL')
		ORDER BY RoleName

		DROP TABLE #tempSource

		DROP TABLE #tempBU_BVA
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                                    
		EXEC AVL_InsertError '[AVL].[BOM_GetAccessDetailsByUserID]'
			,@ErrorMessage
			,0
	END CATCH
END
