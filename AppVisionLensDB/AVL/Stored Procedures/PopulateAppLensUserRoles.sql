/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [AVL].[PopulateAppLensUserRoles]
AS
BEGIN
	BEGIN TRY
		DECLARE @IsActive BIT = 1
		DECLARE @CreatedBy VARCHAR(50) = 'SYSTEM'
		DECLARE @ModifiedBy VARCHAR(50) = 'SYSTEM'
		DECLARE @DataSource VARCHAR(50) = 'RHMS'
		DECLARE @SDMRoleId INT
		DECLARE @SDDRoleId INT
		DECLARE @AccessLevelSourceID INT

		CREATE TABLE #tempSource (
			AssociateId [nvarchar](50) NOT NULL
			,RoleId [int] NOT NULL
			,AccessLevelSourceID [int] NOT NULL
			,AccessLevelId [bigint] NULL
			,IsActive [bit] NOT NULL
			,CreatedBy [varchar](50) NULL
			,CreatedDate [smalldatetime] NULL
			,ModifiedBy [varchar](50) NULL
			,ModifiedDate [smalldatetime] NOT NULL
			,DataSource [varchar](50) NULL
			)

		IF EXISTS (
				SELECT TOP 1 1
				FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails]
				)
		BEGIN
			
			/* Market and Market Unit - Start */
			
			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,mar.MarketID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempMarket
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			JOIN [ESA].[Market] mar ON Mar.MarketName = mrd.PrimaryPortfolioName
			WHERE mrd.AccessLevel = 'Market' AND mrd.PrimaryPortfolioType = 'Market'
			
			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,mu.MarketUnitID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempMarketUnit
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			JOIN [ESA].[MarketUnit] mu ON mu.MarketUnitName = mrd.PrimaryPortfolioName
			WHERE mrd.AccessLevel = 'MU' AND mrd.PrimaryPortfolioType = 'MU'

			/* Market and Market Unit - End */
			
			TRUNCATE TABLE [AVL].[NonESA_RHMSAccounts]

			INSERT INTO [AVL].[NonESA_RHMSAccounts] (
				UserID
				,ESA_AccountID
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				)
			SELECT mrd.AssociateId
				,mrd.PortfolioQualifier1Id AS ESA_AccountID
				,@CreatedBy
				,GETDATE()
				,@ModifiedBy
				,GETDATE()
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] mrd
			LEFT OUTER JOIN [AVL].[Customer] cus ON mrd.PortfolioQualifier1Id = cus.ESA_AccountID
			WHERE AccessLevel = 'Account'
				AND PortfolioQualifier1Type = 'Account'
				AND cus.ESA_AccountID IS NULL

			INSERT INTO [AVL].[NonESA_RHMSAccounts] (
				UserID
				,ESA_AccountID
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				)
			SELECT AssociateId AS UserID
				,PortfolioQualifier1Id AS ESA_AccountID
				,@CreatedBy
				,GETDATE()
				,@ModifiedBy
				,GETDATE()
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] mrd
			LEFT OUTER JOIN [ESA].[BUParentAccounts] pa ON mrd.PortfolioQualifier1Id = pa.ParentCustomerID
			WHERE AccessLevel = 'Account'
				AND PortfolioQualifier1Type = 'Parent Customer'
				AND pa.ParentCustomerID IS NULL

			--INSERT INTO [AVL].[NonESA_RHMSAccounts](UserID, ESA_AccountID, CreatedBy,CreatedDate,ModifiedBy, ModifiedDate)    
			--SELECT AssociateId as UserID, PortfolioQualifier1Id as ESA_AccountID, @CreatedBy, GETDATE(), @ModifiedBy, GETDATE()    
			--FROM [AVL].[MigratedRhmsDetails] mrd    
			--LEFT JOIN [ESA].[BUParentAccounts] pa     
			--ON mrd.PortfolioQualifier1Id =  pa.ParentCustomerID     
			--WHERE AccessLevel = 'Account' AND PortfolioQualifier1Type = 'Parent Customer' AND pa.CustomerID = 0    

			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,pcus.CustomerID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempParentCustomer
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [ESA].[BUParentAccounts] pa ON mrd.PortfolioQualifier1Id = pa.ParentCustomerID
			JOIN [AVL].[Customer] pcus ON pa.ESA_AccountID = pcus.ESA_AccountID
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.PortfolioQualifier1Type = 'Parent Customer'


			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,pcus.CustomerID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempParentRestRoles
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [ESA].[BUParentAccounts] pa ON mrd.primaryportfolioid = pa.ParentCustomerID
			JOIN [AVL].[Customer] pcus ON pa.ESA_AccountID = pcus.ESA_AccountID
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.primaryportfoliotype = 'Parent Customer' 


			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,cus.CustomerID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempAccount
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[Customer] cus ON mrd.PortfolioQualifier1Id = cus.ESA_AccountID
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName AND mrd.AccessLevel = ra.AccessLevel
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.PortfolioQualifier1Type = 'Account'
			AND mrd.AccessLevel ='Account' AND cus.IsDeleted = 0 AND arm.IsActive = 1


			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,cus.CustomerID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempAccountRestRoles
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[Customer] cus ON mrd.primaryportfolioid = cus.ESA_AccountID
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName AND mrd.AccessLevel = ra.AccessLevel
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.primaryportfoliotype = 'Account'
			AND mrd.AccessLevel ='Account' AND cus.IsDeleted = 0 AND arm.IsActive = 1


			SELECT DISTINCT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,pm.ProjectID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempEDLPDLProject
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].BusinessUnit bu on mrd.primaryportfolioname = bu.BUName
			JOIN [AVL].[Customer] cus ON mrd.PortfolioQualifier1id = cus.ESA_AccountID
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName AND mrd.AccessLevel = ra.AccessLevel
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			JOIN AVL.MAS_ProjectMaster pm ON cus.CustomerID = pm.CustomerID
			JOIN dbo.AVM_Project_list pl ON pm.EsaProjectID = pl.ESAProjectID AND pl.PracticeOwnerId = bu.BUID
			WHERE mrd.primaryportfoliotype = 'Horizontal' AND mrd.PortfolioQualifier1type = 'Account' 
			AND bu.IsDeleted = 0 AND cus.IsDeleted = 0 AND arm.IsActive = 1 AND pm.IsDeleted = 0 AND pm.EsaProjectID <> 0 AND pl.IsDeleted = 0
			AND (EXISTS (
				SELECT RhmsRoleName FROM [AVL].RhmsRoleAccessLevels ra1
				WHERE (ra1.RhmsRoleName = 'Engagement Delivery Lead - SL' OR ra1.RhmsRoleName = 'Portfolio Delivery Lead') 
				AND ra.AccessLevel = 'Project'
				AND ra1.RhmsRoleName = ra.RhmsRoleName))



			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,(
					CASE 
						WHEN mrd.AccessLevel = 'BU'
							THEN bu.BUID
						END
					) AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempBU
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[BUMapping] bmap ON mrd.PortfolioQualifier1Name = CASE 
					WHEN mrd.AccessLevel = 'BU'
						THEN bmap.RhmsBUName
					END
			JOIN [AVL].[BusinessUnit] bu ON bmap.AppLensBUName = CASE 
					WHEN mrd.AccessLevel = 'BU'
						THEN bu.BUName
					END
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE bu.IsDeleted = 0

			--Vertical Access Func. Gap Fix			
			SELECT DISTINCT  mrd.AssociateId AS AssociateId
						,arm.RoleId
						,alsm.AccessLevelSourceID				
						,(CASE 
							WHEN mrd.AccessLevel <> 'BU' 
								THEN bu.BUID
							END
						) AS AccessLevelId
						,@IsActive AS IsActive
						,@CreatedBy AS CreatedBy
						,GETDATE() AS CreatedDate
						,@ModifiedBy AS ModifiedBy
						,GETDATE() AS ModifiedDate
						,@DataSource AS DataSource
					INTO #tempPureVertical
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[BUMapping] bmap ON mrd.PrimaryPortfolioName = CASE 
					WHEN mrd.PrimaryPortfolioType = 'Vertical' 
						THEN bmap.RhmsBUName
					END
			JOIN [ESA].[BusinessUnits] bu ON bmap.AppLensBUName = CASE 
					WHEN mrd.PrimaryPortfolioType = 'Vertical' 
						THEN bu.BUName
					END
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName 
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName and arm.IsActive = 1
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE bu.IsActive = 1



			SELECT distinct mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,bu.BUID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempVertical
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [ESA].[BusinessUnits] bu ON mrd.PrimaryPortfolioName = bu.BUName
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.AccessLevel = 'Horizontal'

			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,bu.BUID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempSubHorizontal
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[BusinessUnit] bu ON mrd.PrimaryPortfolioName = bu.BUName
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.AccessLevel = 'Sub Horizontal'
				AND bu.IsHorizontal = 'Y'
				AND bu.IsDeleted = 0

			SELECT mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,bu.BUID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempHorizontal
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [AVL].[BusinessUnit] bu ON mrd.PrimaryPortfolioName = bu.BUName
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE mrd.AccessLevel = 'Horizontal'
				AND bu.IsHorizontal = 'Y'
				AND bu.IsDeleted = 0

		    SELECT distinct mrd.AssociateId AS AssociateId
				,arm.RoleId
				,alsm.AccessLevelSourceID
				,ebu.BusinessUnitID AS AccessLevelId
				,@IsActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempNewBU
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] AS mrd
			JOIN [ESA].[ESABusinessUnit] ebu ON ebu.BusinessUnitName = CASE 
					WHEN mrd.PortfolioQualifier1Type = 'BU' THEN mrd.portfolioqualifier1Name
					WHEN mrd.PrimaryPortfolioType = 'BU'THEN mrd.PrimaryPortfolioName
					END
			JOIN [AVL].[RhmsRoleAccessLevels] ra ON mrd.RoleName = ra.RhmsRoleName
			JOIN [AVL].[RoleMaster] arm ON ra.AppLensRole = arm.RoleName
			JOIN [AVL].[AccessLevelSourceMaster] alsm ON mrd.AccessLevel = alsm.AccessLevel
			WHERE ebu.IsDeleted = 0 AND mrd.AccessLevel = 'New BU'

			/****** SDD / SDM roles are not available under portfolio AVM from MigratedRhmsDetails table - Start ******/
			SELECT @SDMRoleId = RoleId
			FROM AVL.ROLEMASTER
			WHERE RoleName = 'SDM'

			SELECT @SDDRoleId = RoleId
			FROM AVL.ROLEMASTER
			WHERE RoleName = 'SDD'

			SELECT @AccessLevelSourceID = AccessLevelSourceID
			FROM avl.accesslevelsourcemaster
			WHERE AccessLevel = 'Project'

			SELECT gmrd.AssociateID AS AssociateId
				,@SDMRoleId AS RoleId
				,@AccessLevelSourceID AS AccessLevelSourceID
				,pm.ProjectID AS AccessLevelId
				,@isActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempSDM
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] gmrd
			JOIN AVL.MAS_ProjectMaster pm ON gmrd.Project_ID = pm.EsaProjectID
			WHERE gmrd.RoleName = 'Service Delivery Manager' AND pm.EsaProjectID <> 0  AND pm.IsDeleted = 0

			SELECT gmrd.AssociateID AS AssociateId
				,@SDDRoleId AS RoleId
				,@AccessLevelSourceID AS AccessLevelSourceID
				,pm.ProjectID AS AccessLevelId
				,@isActive AS IsActive
				,@CreatedBy AS CreatedBy
				,GETDATE() AS CreatedDate
				,@ModifiedBy AS ModifiedBy
				,GETDATE() AS ModifiedDate
				,@DataSource AS DataSource
			INTO #tempSDD
			FROM [$(AVMCOEESADB)].[dbo].[MigratedRhmsDetails] gmrd
			JOIN AVL.MAS_ProjectMaster pm ON gmrd.Project_ID = pm.EsaProjectID
			WHERE gmrd.RoleName = 'Service Delivery Director' AND pm.EsaProjectID <> 0 AND pm.IsDeleted = 0
			/****** SDD / SDM roles are not available under portfolio AVM from MigratedRhmsDetails table - End ******/


			INSERT INTO #tempSource

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempMarket
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempMarketUnit
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempParentCustomer
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource 
			FROM #tempParentRestRoles

			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempAccount
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource 
			FROM #tempAccountRestRoles

			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource 
			FROM #tempEDLPDLProject

			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempBU

			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempPureVertical
			
			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempVertical
			
			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempSubHorizontal
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempHorizontal

			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempNewBU
			
			UNION

			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempSDD
			
			UNION
			
			SELECT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempSDM

			INSERT INTO [AVL].[UserRoleMapping] (
				EmployeeID
				,RoleID
				,AccessLevelSourceID
				,AccessLevelID
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
				)
			SELECT DISTINCT AssociateId
				,RoleId
				,AccessLevelSourceID
				,AccessLevelId
				,IsActive
				,CreatedBy
				,CreatedDate
				,ModifiedBy
				,ModifiedDate
				,DataSource
			FROM #tempSource src
			WHERE NOT EXISTS (
					SELECT tgt.RoleID
						,tgt.AccessLevelSourceID
						,tgt.EmployeeID
						,tgt.AccessLevelID
					FROM [AVL].[UserRoleMapping] tgt
					WHERE tgt.RoleID = src.RoleId
						AND tgt.AccessLevelSourceID = src.AccessLevelSourceID
						AND tgt.EmployeeID = src.AssociateId
						AND (
							tgt.AccessLevelID = src.AccessLevelId
							OR COALESCE(tgt.AccessLevelID, src.AccessLevelId) IS NULL
							)
					)

			/****** Update associates who are existing in UserRoleMapping table ******/
			UPDATE urm
			SET IsActive = 1
				,ModifiedBy = 'SYSTEM'
				,ModifiedDate = GETDATE()
			FROM [AVL].[UserRoleMapping] urm
			WHERE EXISTS (
					SELECT ts.RoleID
						,ts.AccessLevelSourceID
						,ts.AssociateId
						,ts.AccessLevelID
					FROM #tempSource ts
					WHERE ts.RoleID = urm.RoleID
						AND ts.AccessLevelSourceID = urm.AccessLevelSourceID
						AND ts.AssociateId = urm.EmployeeID
						AND (
							ts.AccesslevelID = urm.AccessLevelID
							OR COALESCE(ts.AccesslevelID, urm.AccessLevelID) IS NULL
							)
					)
				AND urm.DataSource = 'RHMS'
				AND urm.IsActive = 0

			/****** End ******/

			/****** Update DataSource as RHMS for the records which are inserted through UI or Manually if records exist ******/
			UPDATE urm
			SET urm.DataSource = @DataSource
				,urm.ModifiedBy = 'SYSTEM'
				,urm.ModifiedDate = GETDATE()
			FROM [AVL].[UserRoleMapping] urm
			WHERE EXISTS (
					SELECT ts.RoleID
						,ts.AccessLevelSourceID
						,ts.AssociateId
						,ts.AccessLevelID
					FROM #tempSource ts
					WHERE ts.RoleId = urm.RoleID
						AND ts.AccessLevelSourceID = urm.AccessLevelSourceID
						AND ts.AssociateId = urm.EmployeeID
						AND (
							ts.AccessLevelID = urm.AccessLevelId
							OR COALESCE(ts.AccessLevelID, urm.AccessLevelId) IS NULL
							)
					)
				AND (
					urm.DataSource = 'UI'
					OR urm.DataSource = 'Manual'
					)

			/****** End ******/

			/****** Handling inactive associates ******/
			UPDATE urm
			SET urm.IsActive = 0
				,urm.ModifiedBy = 'SYSTEM'
				,urm.ModifiedDate = GETDATE()
			FROM [AVL].[UserRoleMapping] urm
			WHERE NOT EXISTS (
					SELECT ts.RoleID
						,ts.AccessLevelSourceID
						,ts.AssociateId
						,ts.AccessLevelID
					FROM #tempSource ts
					WHERE urm.RoleID = ts.RoleId
						AND urm.AccessLevelSourceID = ts.AccessLevelSourceID
						AND urm.EmployeeID = ts.AssociateId
						AND (
							urm.AccessLevelID = ts.AccessLevelId
							OR COALESCE(urm.AccessLevelID, ts.AccessLevelId) IS NULL
							)
					)
				AND urm.DataSource LIKE '%RHMS%'
				AND urm.IsActive = 1
			/****** End ******/

			DROP TABLE #tempMarket

			DROP TABLE #tempMarketUnit

			DROP TABLE #tempParentCustomer

			DROP TABLE #tempParentRestRoles

			DROP TABLE #tempAccount

			DROP TABLE #tempAccountRestRoles

			DROP TABLE #tempEDLPDLProject

			DROP TABLE #tempBU

			DROP TABLE #tempPureVertical

			DROP TABLE #tempVertical

			DROP TABLE #tempSubHorizontal

			DROP TABLE #tempHorizontal

			DROP TABLE #tempNewBU

			DROP TABLE #tempSDD

			DROP TABLE #tempSDM

			DROP TABLE #tempSource

			TRUNCATE TABLE [AVL].[MigratedRhmsDetails]
		END
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error            
		EXEC AVL_InsertError '[AVL].[PopulateAppLensUserRoles]'
			,@ErrorMessage
			,0
	END CATCH
END
