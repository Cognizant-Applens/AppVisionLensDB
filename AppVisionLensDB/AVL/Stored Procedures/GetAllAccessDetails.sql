/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAllAccessDetails]
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

		CREATE TABLE #tempSource (
			RoleId [int] NOT NULL
			,RoleName NVARCHAR(max) NOT NULL
			,AccessLevel NVARCHAR(50) NOT NULL
			,EmployeeID NVARCHAR(50) NOT NULL
			,EmployeeName NVARCHAR(500) NOT NULL
			,ProjectID [int] NULL
			,ProjectName VARCHAR(200) NULL
			,ESAProjectID VARCHAR(50) NULL
			,CustomerID [int] NULL
			,CustomerName VARCHAR(200) NULL
			,ESAAccountID VARCHAR(50) NULL
			,BUID [int] NULL
			,BUName [varchar](200) NULL
			,IsHorizontal VARCHAR(50) NULL
			,ValidTillDate DATE
			,IsActive INT NULL
			)

		CREATE TABLE #Accomaster (
			AssociateID NVARCHAR(50) NOT NULL
			,AssociateName NVARCHAR(500) NOT NULL
			)

		INSERT INTO #Accomaster (
			AssociateID
			,AssociateName
			) (
			SELECT AssociateID
			,AssociateName FROM [ESA].[Associates]
			)
		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,assomaster.AssociateName AS EmployeeName
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,@ESAProjectID AS ESAProjectID
			,cus.CustomerID
			,cus.CustomerName
			,cus.ESA_AccountID AS ESAAccountID
			,bu.BusinessUnitID AS BUID
			,bu.BusinessUnitName AS BUName
			,bu.IsHorizontal AS IsHorizontal
			,urm.[Valid Till Date]
			,urm.IsActive
		INTO #tempAcc
		FROM [AVL].[UserRoleMapping] urm
		JOIN #Accomaster assomaster ON urm.EmployeeID = assomaster.AssociateID
		JOIN [AVL].[RoleMaster] rm ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].[Customer] cus ON urm.AccessLevelID = cus.CustomerID
		--CASE WHEN alsm.AccessLevel = 'Account'                
		--THEN cus.CustomerID                  
		--END                
		JOIN [MAS].[BusinessUnits] bu ON cus.BusinessUnitID = bu.BusinessUnitID
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Account'
			AND bu.IsDeleted = 0

		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,assomaster.AssociateName AS EmployeeName
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,@ESAProjectID AS ESAProjectID
			,@CustomerID AS CustomerID
			,@CustomerName AS Customername
			,@ESAAccountID AS ESAAccountID
			,bu.BusinessUnitID
			,bu.BusinessUnitName
			,bu.IsHorizontal AS IsHorizontal
			,urm.[Valid Till Date]
			,urm.IsActive
		INTO #tempBU
		FROM [AVL].[UserRoleMapping] urm
		JOIN #Accomaster assomaster ON urm.EmployeeID = assomaster.AssociateID
		JOIN [AVL].[RoleMaster] rm ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [MAS].[BusinessUnits] bu ON urm.AccessLevelID = CASE 
				WHEN alsm.AccessLevel = 'BU'
					OR alsm.AccessLevel = 'Sub Horizontal'
					THEN bu.BusinessUnitID
				END
		WHERE urm.IsActive = 1
			AND bu.IsDeleted = 0

		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,assomaster.AssociateName AS EmployeeName
			,pm.ProjectID AS ProjectID
			,pm.ProjectName AS ProjectName
			,pm.EsaProjectID AS ESAProjectID
			,cus.CustomerID
			,cus.CustomerName
			,cus.ESA_AccountID AS ESAAccountID
			,bu.BusinessUnitID
			,bu.BusinessUnitName
			,bu.IsHorizontal AS IsHorizontal
			,urm.[Valid Till Date]
			,urm.IsActive
		INTO #tempProject
		FROM [AVL].[UserRoleMapping] urm
		JOIN #Accomaster assomaster ON urm.EmployeeID = assomaster.AssociateID
		JOIN [AVL].[RoleMaster] rm ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
		JOIN [AVL].MAS_ProjectMaster pm ON urm.AccessLevelID = pm.ProjectID
		JOIN [AVL].[Customer] cus ON pm.CustomerID = cus.CustomerID
		JOIN [MAS].[BusinessUnits] bu ON cus.BusinessUnitID = bu.BusinessUnitID
		WHERE urm.IsActive = 1
			AND alsm.AccessLevel = 'Project'
			AND bu.IsDeleted = 0

		SELECT rm.RoleId
			,rm.RoleName
			,alsm.AccessLevel
			,urm.EmployeeID
			,assomaster.AssociateName AS EmployeeName
			,@ProjID AS ProjectID
			,@ProjName AS ProjectName
			,@ESAProjectID AS ESAProjectID
			,@CustomerID AS CustomerID
			,@CustomerName AS CustomerName
			,@ESAAccountID AS ESAAccountID
			,bu.BusinessUnitID AS BUID
			,bu.BusinessUnitName AS BUName
			,bu.IsHorizontal AS IsHorizontal
			,urm.[Valid Till Date]
			,urm.IsActive
		INTO #tempHorizontal
		FROM [AVL].[UserRoleMapping] urm
		JOIN #Accomaster assomaster ON urm.EmployeeID = assomaster.AssociateID
		JOIN [AVL].[RoleMaster] rm ON urm.RoleID = rm.RoleId
		JOIN [AVL].[AccessLevelSourceMaster] alsm ON urm.AccessLevelSourceID = alsm.AccessLevelSourceID
			,[MAS].[BusinessUnits] bu
		WHERE alsm.AccessLevel = 'Horizontal'
			AND urm.IsActive = 1
			AND bu.IsHorizontal = 'N'
			AND bu.BusinessUnitName != 'AVM'
			AND bu.IsDeleted = 0

		INSERT INTO #tempSource
		SELECT *
		FROM #tempAcc
		
		UNION
		
		SELECT *
		FROM #tempBU
		
		UNION
		
		SELECT *
		FROM #tempProject
		
		UNION
		
		SELECT *
		FROM #tempHorizontal

		SELECT *
		FROM #tempSource

		--where EmployeeID = @UserID            
		DROP TABLE #tempAcc

		DROP TABLE #tempBU

		DROP TABLE #tempProject

		DROP TABLE #tempHorizontal

		DROP TABLE #tempSource

		DROP TABLE #Accomaster
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                    
		EXEC AVL_InsertError '[AVL].[GetAllAccessDetails]'
			,@ErrorMessage
			,0
	END CATCH
END
