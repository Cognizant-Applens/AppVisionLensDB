/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAllAccessDetailsForRoles] @BUIDList VARCHAR(800) = NULL
	,@RoleID VARCHAR(10) = NULL
	,@EmployeeIDList VARCHAR(50) = NULL
	,@ProjectIDList VARCHAR(max) = NULL
	,@CustmoreIDList VARCHAR(max) = NULL
AS
BEGIN
	BEGIN TRY
		DECLARE @ProjID VARCHAR(50) = NULL
		DECLARE @ProjName VARCHAR(50) = NULL
		DECLARE @CustomerID BIGINT = NULL
		DECLARE @CustomerName VARCHAR(50) = NULL
		DECLARE @BUID VARCHAR(50) = NULL
		DECLARE @BUName VARCHAR(50) = NULL
		DECLARE @ESAAccountID VARCHAR(50) = NULL
		DECLARE @ESAProjectID VARCHAR(50) = NULL
		DECLARE @RoleName VARCHAR(50) = NULL
		DECLARE @AccessLevel VARCHAR(50) = NULL

		CREATE TABLE #Accomaster (
			EmployeeID NVARCHAR(50) NOT NULL
			,AssociateName NVARCHAR(500) NOT NULL
			,IsActive BIT NOT NULL
			)

		INSERT INTO #Accomaster (
			EmployeeID
			,AssociateName
			,IsActive
			) (
			SELECT AssociateID
			,AssociateName
			,IsActive FROM [ESA].[Associates]
			)

		CREATE TABLE #tempSource (
			RoleId [int] NOT NULL
			,RoleName NVARCHAR(50) NOT NULL
			,AccessLevel NVARCHAR(50) NOT NULL
			,EmployeeID NVARCHAR(50) NOT NULL
			,EmployeeName NVARCHAR(100) NULL
			,ProjectID [int] NULL
			,ProjectName VARCHAR(100) NULL
			,ESAProjectID VARCHAR(50) NULL
			,CustomerID [int] NULL
			,CustomerName VARCHAR(100) NULL
			,ESAAccountID VARCHAR(50) NULL
			,BUID [int] NULL
			,BUName [varchar](50) NULL
			,IsHorizontal VARCHAR(50) NULL
			,ValidTillDate DATE
			,IsActive INT NULL
			,DataSource VARCHAR(50) NULL
			,Comments NVARCHAR(255) NULL
			,IsEmployeeActive CHAR NULL
			)

		IF (@EmployeeIDList IS NOT NULL)
		BEGIN
			INSERT INTO #tempSource
			SELECT rm.RoleId
				,rm.RoleName
				,alsm.AccessLevel
				,urm.EmployeeID
				,associate.AssociateName AS EmployeeName
				,@ProjID AS ProjectID
				,@ProjName AS ProjectName
				,@ESAProjectID AS ESAProjectID
				,cus.CustomerID
				,cus.CustomerName
				,cus.ESA_AccountID AS ESAAccountID
				,bu.BUID AS BUID
				,bu.BUName AS BUName
				,bu.IsHorizontal AS IsHorizontal
				,urm.[Valid Till Date]
				,urm.IsActive
				,urm.DataSource
				,urm.Comments
				,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			INNER JOIN [AVL].[Customer] cus(NOLOCK) ON urm.AccessLevelID = cus.CustomerID
			INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON cus.BUID = bu.BUID
			WHERE urm.IsActive = 1
				AND alsm.AccessLevel = 'Account'
				AND bu.IsDeleted = 0
				AND cus.IsDeleted = 0
				AND urm.EmployeeID = @EmployeeIDList

			INSERT INTO #tempSource
			SELECT rm.RoleId
				,rm.RoleName
				,alsm.AccessLevel
				,urm.EmployeeID
				,associate.AssociateName AS EmployeeName
				,@ProjID AS ProjectID
				,@ProjName AS ProjectName
				,@ESAProjectID AS ESAProjectID
				,@CustomerID AS CustomerID
				,@CustomerName AS Customername
				,@ESAAccountID AS ESAAccountID
				,bu.BUID
				,bu.BUName
				,bu.IsHorizontal AS IsHorizontal
				,urm.[Valid Till Date]
				,urm.IsActive
				,urm.DataSource
				,urm.Comments
				,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON urm.AccessLevelID = bu.BUID
			WHERE urm.IsActive = 1
				AND bu.IsDeleted = 0
				AND (
					alsm.AccessLevel = 'BU'
					OR alsm.AccessLevel = 'Sub Horizontal'
					)
				AND urm.EmployeeID = @EmployeeIDList

			INSERT INTO #tempSource
			SELECT rm.RoleId
				,rm.RoleName
				,alsm.AccessLevel
				,urm.EmployeeID
				,associate.AssociateName AS EmployeeName
				,pm.ProjectID AS ProjectID
				,pm.ProjectName AS ProjectName
				,pm.EsaProjectID AS ESAProjectID
				,cus.CustomerID
				,cus.CustomerName
				,cus.ESA_AccountID AS ESAAccountID
				,bu.BUID
				,bu.BUName
				,bu.IsHorizontal AS IsHorizontal
				,urm.[Valid Till Date]
				,urm.IsActive
				,urm.DataSource
				,urm.Comments
				,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			INNER JOIN [AVL].MAS_ProjectMaster pm(NOLOCK) ON urm.AccessLevelID = pm.ProjectID
			INNER JOIN [AVL].[Customer] cus(NOLOCK) ON pm.CustomerID = cus.CustomerID
			INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON cus.BUID = bu.BUID
			WHERE urm.IsActive = 1
				AND alsm.AccessLevel = 'Project'
				AND bu.IsDeleted = 0
				AND urm.EmployeeID = @EmployeeIDList
				AND pm.IsDeleted = 0
				AND cus.IsDeleted = 0

			INSERT INTO #tempSource
			SELECT rm.RoleId
				,rm.RoleName
				,alsm.AccessLevel
				,urm.EmployeeID
				,associate.AssociateName AS EmployeeName
				,@ProjID AS ProjectID
				,@ProjName AS ProjectName
				,@ESAProjectID AS ESAProjectID
				,@CustomerID AS CustomerID
				,@CustomerName AS CustomerName
				,@ESAAccountID AS ESAAccountID
				,@BUID AS BUID
				,@BUName AS BUName
				,'' AS IsHorizontal
				,urm.[Valid Till Date]
				,urm.IsActive
				,urm.DataSource
				,urm.Comments
				,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON bu.BUID = urm.AccessLevelID
			WHERE alsm.AccessLevel = 'Horizontal'
				AND urm.IsActive = 1
				AND bu.IsHorizontal = 'N'
				AND bu.BUName != 'AVM'
				AND bu.IsDeleted = 0
				AND urm.EmployeeID = @EmployeeIDList

			INSERT INTO #tempSource
			SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,@CustomerID AS CustomerID
					,@CustomerName AS CustomerName
					,@ESAAccountID AS ESAAccountID
					,bu.BUID AS BUID
					,bu.BUName AS BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON bu.BUID = urm.AccessLevelID
			WHERE alsm.AccessLevel = 'Horizontal'
				AND urm.IsActive = 1
				AND bu.IsDeleted = 0
				AND urm.EmployeeID = @EmployeeIDList

			INSERT INTO #tempSource
			SELECT rm.RoleId
				,rm.RoleName
				,alsm.AccessLevel
				,urm.EmployeeID
				,associate.AssociateName AS EmployeeName
				,@ProjID AS ProjectID
				,@ProjName AS ProjectName
				,@ESAProjectID AS ESAProjectID
				,@CustomerID AS CustomerID
				,@CustomerName AS CustomerName
				,@ESAAccountID AS ESAAccountID
				,@BUID AS BUID
				,@BUName AS BUName
				,'' AS IsHorizontal
				,urm.[Valid Till Date]
				,urm.IsActive
				,urm.DataSource
				,urm.Comments
				,associate.IsActive
			FROM [AVL].[UserRoleMapping] urm(NOLOCK)
			LEFT JOIN #Accomaster associate ON associate.EmployeeID = urm.EmployeeID
			INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
			INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			WHERE alsm.AccessLevel = 'Admin'
				AND urm.IsActive = 1
				AND urm.EmployeeID = @EmployeeIDList

			SELECT *
			FROM #tempSource
		END
		ELSE
		BEGIN
			SELECT @AccessLevel = AccessLevel
			FROM avl.AccessLevelMapping
			WHERE RoleName = (
					SELECT RoleName
					FROM avl.RoleMaster
					WHERE RoleId = @RoleID
					)

			IF (@AccessLevel = 'Account')
			BEGIN
				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,cus.CustomerID
					,cus.CustomerName
					,cus.ESA_AccountID AS ESAAccountID
					,bu.BUID AS BUID
					,bu.BUName AS BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				INNER JOIN [AVL].[Customer](NOLOCK) cus ON urm.AccessLevelID = cus.CustomerID
				INNER JOIN [AVL].[BusinessUnit](NOLOCK) bu ON cus.BUID = bu.BUID
				WHERE urm.IsActive = 1
					AND alsm.AccessLevel = 'Account'
					AND bu.IsDeleted = 0
					AND cus.IsDeleted = 0
					AND urm.RoleID = @RoleID
			END
			ELSE IF (@AccessLevel = 'None')
			BEGIN
				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,@CustomerID AS CustomerID
					,@CustomerName AS CustomerName
					,@ESAAccountID AS ESAAccountID
					,@BUID AS BUID
					,@BUName AS BUName
					,'' AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				WHERE alsm.AccessLevel = 'Admin'
					AND urm.IsActive = 1
					AND urm.RoleID = @RoleID
			END
			ELSE IF (@AccessLevel = 'BU')
			BEGIN
				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,@CustomerID AS CustomerID
					,@CustomerName AS Customername
					,@ESAAccountID AS ESAAccountID
					,bu.BUID
					,bu.BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				INNER JOIN [AVL].[BusinessUnit](NOLOCK) bu ON urm.AccessLevelID = bu.BUID
				WHERE urm.IsActive = 1
					AND bu.IsDeleted = 0
					AND (
						alsm.AccessLevel = 'BU'
						OR alsm.AccessLevel = 'Sub Horizontal'
						)
					AND urm.RoleID = @RoleID

				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,@CustomerID AS CustomerID
					,@CustomerName AS CustomerName
					,@ESAAccountID AS ESAAccountID
					,bu.BUID AS BUID
					,bu.BUName AS BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON bu.BUID = urm.AccessLevelID
				WHERE alsm.AccessLevel = 'Horizontal'
					AND urm.IsActive = 1
					AND bu.IsHorizontal = 'N'
					AND bu.BUName != 'AVM'
					AND bu.IsDeleted = 0
					AND urm.RoleID = @RoleID
			END
			ELSE IF (@AccessLevel = 'Horizontal')
			BEGIN
				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,@ProjID AS ProjectID
					,@ProjName AS ProjectName
					,@ESAProjectID AS ESAProjectID
					,@CustomerID AS CustomerID
					,@CustomerName AS CustomerName
					,@ESAAccountID AS ESAAccountID
					,bu.BUID AS BUID
					,bu.BUName AS BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON bu.BUID = urm.AccessLevelID
				WHERE alsm.AccessLevel = 'Horizontal'
					AND urm.IsActive = 1
					AND bu.IsDeleted = 0
					AND urm.RoleID = @RoleID
			END
			ELSE IF (@AccessLevel = 'Project')
			BEGIN
				INSERT INTO #tempSource
				SELECT DISTINCT rm.RoleId
					,rm.RoleName
					,alsm.AccessLevel
					,urm.EmployeeID
					,associate.AssociateName AS EmployeeName
					,pm.ProjectID AS ProjectID
					,pm.ProjectName AS ProjectName
					,pm.EsaProjectID AS ESAProjectID
					,cus.CustomerID
					,cus.CustomerName
					,cus.ESA_AccountID AS ESAAccountID
					,bu.BUID
					,bu.BUName
					,bu.IsHorizontal AS IsHorizontal
					,urm.[Valid Till Date]
					,urm.IsActive
					,urm.DataSource
					,urm.Comments
					,associate.IsActive
				FROM [AVL].[UserRoleMapping] urm(NOLOCK)
				LEFT JOIN #Accomaster associate ON urm.EmployeeID = associate.EmployeeID
				INNER JOIN [AVL].[RoleMaster](NOLOCK) rm ON urm.RoleID = rm.RoleId
				INNER JOIN [AVL].[AccessLevelSourceMaster](NOLOCK) alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
				INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) pm ON urm.AccessLevelID = pm.ProjectID
				INNER JOIN [AVL].[Customer](NOLOCK) cus ON pm.CustomerID = cus.CustomerID
				INNER JOIN [AVL].[BusinessUnit](NOLOCK) bu ON cus.BUID = bu.BUID
				WHERE urm.IsActive = 1
					AND alsm.AccessLevel = 'Project'
					AND bu.IsDeleted = 0
					AND cus.IsDeleted = 0
					AND pm.IsDeleted = 0
					AND urm.RoleID = @RoleID
			END

			CREATE TABLE #BU (BUID INT)

			CREATE TABLE #Employee (EmployeeID INT)

			CREATE TABLE #Project (ProjectID INT)

			CREATE TABLE #Customer (CustomerID INT)

			INSERT INTO #BU
			SELECT CAST(Item AS INTEGER)
			FROM dbo.SplitString(@BUIDList, ',')

			DECLARE @BUI INT

			SET @BUI = (
					SELECT TOP 1 BUID
					FROM #BU
					)

			INSERT INTO #Employee
			SELECT CAST(Item AS INTEGER)
			FROM dbo.SplitString(@EmployeeIDList, ',')

			DECLARE @EID INT

			SET @EID = (
					SELECT TOP 1 EmployeeID
					FROM #Employee
					)

			INSERT INTO #Customer
			SELECT CAST(Item AS INTEGER)
			FROM dbo.SplitString(@CustmoreIDList, ',')

			DECLARE @CID INT

			SET @CID = (
					SELECT TOP 1 CustomerID
					FROM #Customer
					)

			INSERT INTO #Project
			SELECT CAST(Item AS INTEGER)
			FROM dbo.SplitString(@ProjectIDList, ',')

			DECLARE @PID INT

			SET @PID = (
					SELECT TOP 1 ProjectID
					FROM #Project
					)

			SELECT mastert.*
			FROM #tempSource mastert
			WHERE (
					@BUI IS NULL
					OR mastert.BUID IN (
						SELECT BUID
						FROM #BU
						)
					)
				AND (
					@CID IS NULL
					OR mastert.CustomerID IN (
						SELECT CustomerID
						FROM #Customer
						)
					)
				AND (
					@PID IS NULL
					OR mastert.ProjectID IN (
						SELECT ProjectID
						FROM #Project
						)
					)
				AND @EID IS NULL
				OR mastert.EmployeeID IN (
					SELECT EmployeeID
					FROM #Employee
					)

			DROP TABLE #BU

			DROP TABLE #Employee

			DROP TABLE #Customer

			DROP TABLE #Project

			DROP TABLE #tempSource

			DROP TABLE #Accomaster
		END
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                                             
		EXEC AVL_InsertError '[AVL].[GetAllAccessDetailsForRoles]'
			,@ErrorMessage
			,0
	END CATCH
END
