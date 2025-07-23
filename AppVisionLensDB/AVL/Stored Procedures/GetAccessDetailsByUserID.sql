/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

----------------[AVL].[GetAccessDetailsByUserID] - Start----------------------
CREATE PROCEDURE [AVL].[GetAccessDetailsByUserID] @UserID NVARCHAR(50)
AS
BEGIN

	BEGIN TRY
		DECLARE @ProjID VARCHAR(50) = NULL
		DECLARE @ProjName VARCHAR(50) = NULL
		DECLARE @CustomerID BIGINT = NULL
		DECLARE @CustomerName VARCHAR(50) = NULL
		DECLARE @BUID VARCHAR(50) = NULL
		DECLARE @BUName VARCHAR(50) = NULL
		DECLARE @NewBUID VARCHAR(50) = NULL
		DECLARE @NewBUName VARCHAR(50) = NULL
		DECLARE @ESAAccountID VARCHAR(50) = NULL
		DECLARE @ESAProjectID VARCHAR(50) = NULL
		DECLARE @MarketUnitID INT = NULL
		DECLARE @MarketUnitName NVARCHAR(510) = NULL
		DECLARE @MarketID INT = NULL
		DECLARE @MarketName NVARCHAR(510) = NULL

		CREATE TABLE #tempSource (
			RoleId [int] NOT NULL
			,RoleName NVARCHAR(max) NOT NULL
			,AccessLevel NVARCHAR(50) NOT NULL
			,EmployeeID NVARCHAR(50) NOT NULL
			,ProjectID [int] NULL
			,ProjectName VARCHAR(200) NULL
			,ESAProjectID VARCHAR(50) NULL
			,CustomerID [int] NULL
			,CustomerName VARCHAR(200) NULL
			,ESAAccountID VARCHAR(50) NULL
			,BUID [int] NULL
			,BUName VARCHAR(200) NULL
			,MarketUnitID [int] NULL
			,MarketUnitName NVARCHAR(510) NULL
			,MarketID [int] NULL
			,MarketName NVARCHAR(510) NULL
			,NewBUID [int] NULL
			,NewBUName VARCHAR(200) NULL
			)

		-- Market
		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,ISNULL(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,ISNULL(@ESAProjectID, 0) AS ESAProjectID
			,ISNULL(@CustomerID, 0) AS CustomerID
			,@CustomerName AS CustomerName
			,ISNULL(@ESAAccountID, 0) AS ESAAccountID
			,ISNULL(@BUID, 0) AS BUID
			,@BUName AS BUName
			,ISNULL(@MarketUnitID, 0) AS MarketUnitID
			,@MarketUnitName AS MarketUnitName
			,m.MarketID
			,m.MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [ESA].[Market] m (NOLOCK) ON urm.AccessLevelID = m.MarketID
		WHERE urm.IsActive = 1 AND alsm.AccessLevel = 'Market'
			AND m.IsDeleted = 0 AND urm.EmployeeID = @UserID

		-- Market Unit
		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,ISNULL(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,ISNULL(@ESAProjectID, 0) AS ESAProjectID
			,ISNULL(@CustomerID, 0) AS CustomerID
			,@CustomerName AS CustomerName
			,ISNULL(@ESAAccountID, 0) AS ESAAccountID
			,ISNULL(@BUID, 0) AS BUID
			,@BUName AS BUName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [ESA].[MarketUnit] mu (NOLOCK) ON urm.AccessLevelID = mu.MarketUnitID
		JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE urm.IsActive = 1 AND alsm.AccessLevel = 'MU'
			AND mu.IsDeleted = 0 AND m.IsDeleted = 0
			AND urm.EmployeeID = @UserID

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,cus.CustomerID
			,cus.CustomerName
			,cus.ESA_AccountID AS ESAAccountID
			,bu.BusinessUnitID AS BUID
			,bu.BusinessUnitName AS BUName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,ebu.BusinessUnitID as NewBUID
			,ebu.BusinessUnitName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].[Customer] cus(NOLOCK) ON urm.AccessLevelID = cus.CustomerID
		JOIN [MAS].[BusinessUnits] bu(NOLOCK) ON cus.BusinessUnitID = bu.BusinessUnitID
		LEFT JOIN [ESA].[ESABusinessUnit] ebu (NOLOCK) ON cus.BusinessUnitID = ebu.BusinessUnitID -- New Business Unit
		LEFT JOIN [ESA].[MarketUnit] mu (NOLOCK) ON ebu.MarketUnitID = mu.MarketUnitID
		LEFT JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Account'
			AND bu.IsDeleted = 0
			AND cus.IsDeleted = 0
			AND urm.EmployeeID = @UserID

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,isnull(@CustomerID, 0) AS CustomerID
			,@CustomerName AS Customername
			,isnull(@ESAAccountID, 0) AS ESAAccountID
			,bu.BusinessUnitID
			,bu.BusinessUnitName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [MAS].[BusinessUnits] bu(NOLOCK) ON urm.AccessLevelID = CASE 
				WHEN alsm.AccessLevel = 'BU'
					OR alsm.AccessLevel = 'Sub Horizontal'
					AND bu.IsDeleted = 0
					THEN bu.BusinessUnitID
				END
		JOIN [AVL].[Customer] cus(NOLOCK) ON bu.BusinessUnitID = cus.BusinessUnitID
		LEFT JOIN [ESA].[ESABusinessUnit] ebu (NOLOCK) ON cus.BusinessUnitID = ebu.BusinessUnitID -- New Business Unit
		LEFT JOIN [ESA].[MarketUnit] mu (NOLOCK) ON ebu.MarketUnitID = mu.MarketUnitID
		LEFT JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE urm.IsActive = 1
			AND urm.EmployeeID = @UserID

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,isnull(@CustomerID, 0) AS CustomerID
			,@CustomerName AS Customername
			,isnull(@ESAAccountID, 0) AS ESAAccountID
			,@BUID
			,@BUName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,ebu.BusinessUnitID
			,ebu.BusinessUnitName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [ESA].[ESABusinessUnit] ebu(NOLOCK) ON urm.AccessLevelID = CASE 
				WHEN alsm.AccessLevel = 'New BU'
					AND ebu.IsDeleted = 0
					THEN ebu.BusinessUnitID
				END
		LEFT JOIN [ESA].[MarketUnit] mu (NOLOCK) ON ebu.MarketUnitID = mu.MarketUnitID
		LEFT JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE urm.IsActive = 1
			AND urm.EmployeeID = @UserID

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,pm.ProjectID AS ProjectID
			,pm.ProjectName AS ProjectName
			,pm.EsaProjectID AS ESAProjectID
			,cus.CustomerID
			,cus.CustomerName
			,cus.ESA_AccountID AS ESAAccountID
			,bu.BusinessUnitID
			,bu.BusinessUnitName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,ebu.BusinessUnitID
			,ebu.BusinessUnitName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].MAS_ProjectMaster pm(NOLOCK) ON urm.AccessLevelID = pm.ProjectID
		JOIN [AVL].[Customer] cus(NOLOCK) ON pm.CustomerID = cus.CustomerID
		JOIN [MAS].[BusinessUnits] bu(NOLOCK) ON cus.BusinessUnitID = bu.BusinessUnitID
		LEFT JOIN [ESA].[ESABusinessUnit] ebu (NOLOCK) ON cus.BusinessUnitID = ebu.BusinessUnitID -- New Business Unit
		LEFT JOIN [ESA].[MarketUnit] mu (NOLOCK) ON ebu.MarketUnitID = mu.MarketUnitID
		LEFT JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Project'
			AND bu.IsDeleted = 0
			AND urm.EmployeeID = @UserID
			AND pm.IsDeleted = 0
			AND cus.IsDeleted = 0

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,isnull(@CustomerID, 0) AS CustomerID
			,@CustomerName AS CustomerName
			,isnull(@ESAAccountID, 0) AS ESAAccountID
			,bu.BUID AS BUID
			,bu.BUName AS BUName
			,ISNULL(@MarketUnitID, 0) AS MarketUnitID
			,@MarketUnitName AS MarketUnitName
			,ISNULL(@MarketID, 0) AS MarketID
			,@MarketName AS MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].[BusinessUnit] bu (NOLOCK) ON bu.BUID = urm.AccessLevelID
		WHERE alsm.AccessLevel = 'Horizontal'
			AND urm.IsActive = 1
			AND bu.IsHorizontal = 'N'
			AND bu.BUName != 'AVM'
			AND bu.IsDeleted = 0
			AND urm.EmployeeID = @UserID

			INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,isnull(@CustomerID, 0) AS CustomerID
			,@CustomerName AS CustomerName
			,isnull(@ESAAccountID, 0) AS ESAAccountID
			,bu.BusinessUnitID AS BUID
			,bu.BusinessUnitName AS BUName
			,mu.MarketUnitID
			,mu.MarketUnitName
			,m.MarketID
			,m.MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm(NOLOCK) ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [MAS].[BusinessUnits] bu (NOLOCK) ON bu.BusinessUnitID = urm.AccessLevelID
		LEFT JOIN [AVL].[Customer] cus(NOLOCK) ON bu.BusinessUnitID = cus.BusinessUnitID
		LEFT JOIN [ESA].[ESABusinessUnit] ebu (NOLOCK) ON cus.BusinessUnitID = ebu.BusinessUnitID -- New Business Unit
		LEFT JOIN [ESA].[MarketUnit] mu (NOLOCK) ON ebu.MarketUnitID = mu.MarketUnitID
		LEFT JOIN [ESA].[Market] m (NOLOCK) ON mu.MarketID = m.MarketID
		WHERE alsm.AccessLevel = 'Horizontal'
			AND urm.IsActive = 1
			--AND bu.IsHorizontal = 'N'
			--AND bu.BUName != 'AVM'
			AND bu.IsDeleted = 0
			AND urm.EmployeeID = @UserID

		INSERT INTO #tempSource
		SELECT rm.RoleId
			,rm.RoleName
			,acm.AccessLevel
			,--alsm.AccessLevel,            
			urm.EmployeeID
			,isnull(@ProjID, 0) AS ProjectID
			,@ProjName AS ProjectName
			,isnull(@ESAProjectID, 0) AS ESAProjectID
			,isnull(@CustomerID, 0) AS CustomerID
			,@CustomerName AS CustomerName
			,isnull(@ESAAccountID, 0) AS ESAAccountID
			,@BUID AS BUID
			,@BUName AS BUName
			,ISNULL(@MarketUnitID, 0) AS MarketUnitID
			,@MarketUnitName AS MarketUnitName
			,ISNULL(@MarketID, 0) AS MarketID
			,@MarketName AS MarketName
			,@NewBUID as NewBUID
			,@NewBUName as NewBUName
		FROM [AVL].[UserRoleMapping] urm(NOLOCK)
		JOIN [AVL].[RoleMaster] rm(NOLOCK) ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelMapping] acm(NOLOCK) ON rm.RoleName = acm.RoleName
		WHERE urm.IsActive = 1
			AND acm.AccessLevel NOT IN (
				'Project'
				,'Account'
				,'BU'
				,'MU'
				,'Market'
				,'Horizontal'
				)
			AND urm.EmployeeID = @UserID

		SELECT DISTINCT *
		FROM #tempSource

		DROP TABLE #tempSource
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                    
		EXEC AVL_InsertError '[AVL].[GetAccessDetailsByUserID]'
			,@ErrorMessage
			,0
	END CATCH
END
