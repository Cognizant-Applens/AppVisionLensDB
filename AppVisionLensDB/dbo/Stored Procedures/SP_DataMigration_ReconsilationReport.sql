/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [dbo].[SP_DataMigration_ReconsilationReport]
--(
--	@ESAAccountIDs NVARCHAR(MAX), -- ESA ACCOUNT ID
--	@ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
--)
AS
BEGIN

	---------- Get all projects or specific project(s) for the Accounts ----------
	--SELECT Item AS ESAAccountID INTO #ESAAccountIds FROM dbo.Split(@ESAAccountIDs, ',')
	--SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

	DECLARE @ProjectDetails TABLE 
	( 
		ESAAccountID INT,
		DARTAccountName NVARCHAR(MAX),
		AppLensAccountName NVARCHAR(MAX),
		DARTAccountID BIGINT,
		AppLensAccountID BIGINT,
		ESAProjectID NVARCHAR(100),
		DARTProjectName NVARCHAR(50),
		AppLensProjectName NVARCHAR(100),
		DARTProjectID BIGINT,
		ALProjectID BIGINT
	)

	DECLARE @AppInventoryProjectDetails TABLE 
	( 
		ESAAccountID INT,
		DARTAccountName NVARCHAR(MAX),
		AppLensAccountName NVARCHAR(MAX),
		DARTAccountID BIGINT,
		AppLensAccountID BIGINT,
		ESAProjectID NVARCHAR(100),
		DARTProjectName NVARCHAR(50),
		AppLensProjectName NVARCHAR(100),
		DARTProjectID BIGINT,
		ALProjectID BIGINT
	)

	INSERT INTO @ProjectDetails
		SELECT	distinct DACC.AccountID AS AccountID, 
				DACC.AccountName, 
				CUST.CustomerName, 
				DACC.DeptAccountID,
				CUST.CustomerID,
				DARTPM.ESAProjectID,
				DARTPM.ProjectName,
				APLPM.ProjectName,
				DARTPM.ProjectID, 
				APLPM.ProjectID
		FROM AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DACC
		JOIN AVL.Customer (NOLOCK) CUST
			ON CUST.ESA_AccountID = DACC.AccountID AND CUST.IsDeleted = 0
		JOIN AVMDART.MAS.ProjectMaster (NOLOCK) DARTPM
			ON -- DACC.AccountID IN (SELECT ESAAccountID FROM #ESAAccountIds) AND
				DARTPM.DeptAccountID = DACC.DeptAccountID
				AND DACC.IsDeleted = 'N' 
				AND DARTPM.IsDeleted = 'N'
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
			ON APLPM.EsaProjectID = DARTPM.EsaProjectID --AND APLPM.EsaProjectID =  '1000166496'
	   JOIN DataMigration_Projects (NOLOCK) DP ON DP.ProjectID = APLPM.ProjectID 
		  --and dp.EsaProjectID in (1000160351, 1000234601)
		--join DataMigrationLog (NOLOCK) DL on DL.accountid=DP.ESA_Accountid
		
		
		INSERT INTO @AppInventoryProjectDetails
		SELECT	distinct DACC.AccountID AS AccountID, 
				DACC.AccountName, 
				CUST.CustomerName, 
				DACC.DeptAccountID,
				CUST.CustomerID,
				DARTPM.ESAProjectID,
				DARTPM.ProjectName,
				APLPM.ProjectName,
				DARTPM.ProjectID, 
				APLPM.ProjectID
		FROM AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DACC
		JOIN AVL.Customer (NOLOCK) CUST
			ON CUST.ESA_AccountID = DACC.AccountID AND CUST.IsDeleted = 0
		JOIN AVMDART.MAS.ProjectMaster (NOLOCK) DARTPM
			ON DARTPM.DeptAccountID = DACC.DeptAccountID
				AND DACC.IsDeleted = 'N' AND DARTPM.IsDeleted = 'N'
		JOIN DataMigration_Projects (NOLOCK) DP ON DP.ESA_AccountID = CUST.ESA_AccountID 
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
			ON APLPM.EsaProjectID = DARTPM.EsaProjectID AND APLPM.IsMigratedFromDART = 1
--		 AND APLPM.EsaProjectID in 
--			('1000226441',
--'1000219080',
--'1000227512',
--'1000196292',
--'1000196882',
--'1000112779'
--)  --AND APLPM.IsDeleted = 0
		
		--JOIN DataMigrationLog (NOLOCK) DL ON DL.AccountID = DP.ESA_AccountID AND TicketingModuleStatus = 'S' and DL.id not in (1, 2, 3)
		--WHERE @ESAProjectIDs IS NULL OR DARTPM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)

		--select * from DataMigrationLog (NOLOCK) DL where TicketingModuleStatus = 'S' and id not in (1, 2, 3)

		--select * from @ProjectDetails

	--DROP TABLE #ESAProjectIds 
				
	------------------------------------------------------------------------------------------
	BEGIN TRY

		----------------------------------- App Inventory --------------------------
	
		SELECT DISTINCT P.ESAAccountID, P.DARTAccountName, P.AppLensAccountName, 
			
			-- LOB
			(
				SELECT COUNT(DISTINCT LOB.LobName) FROM AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
			) AS DARTLOBTotalRecordCount,
			 (
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NULL AND CreatedBy = 'Migrated'
			) AS AppLensLOBTotalRecordCount,
			(
				SELECT COUNT(DISTINCT LOB.LobName) FROM AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				WHERE ISNULL(LOB.IsDeleted, 'N') = 'N' AND ISNULL(LOB.IsHidden, 0) = 0
			) AS DARTLOBActiveRecordCount,
			(
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NULL AND IsDeleted = 0
					AND CreatedBy = 'Migrated'
			) AS AppLensLOBActiveRecordCount,
			
			-- TRACK
			(
				SELECT COUNT(DISTINCT TRACK.TrackName) FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
			) AS DARTTRACKTotalRecordCount,
			(
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NOT NULL 
					AND IsHavingSubBusinesss = 1 AND CreatedBy = 'Migrated'
			) AS AppLensTRACKTotalRecordCount,
			(
				SELECT COUNT(DISTINCT TRACK.TrackName) FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				WHERE ISNULL(TRACK.IsDeleted, 'N') = 'N' AND ISNULL(TRACK.IsHidden, 0) = 0 
			) AS DARTTRACKActiveRecordCount,
			(
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NOT NULL AND IsHavingSubBusinesss = 1 
					AND IsDeleted = 0 AND CreatedBy = 'Migrated' 
			) AS AppLensTRACKActiveRecordCount,
			
			-- App Group
			(
				SELECT COUNT(Distinct AGM.AppGroupName) FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				JOIN [AVMDART].[MAP].[LOBTRACKAPPLICATIONMAPPING] (NOLOCK) LTAM 
					ON LTAM.LOBTRACKID = TRACK.LOBTRACKID 
				JOIN [AVMDART].[MAS].[APPLICATIONMASTER] (NOLOCK) AM 
					ON AM.APPTRACKID = LTAM.APPLICATIONTRACKID
				JOIN [AVMDART].[MAP].[APPGROUPMASTER] (NOLOCK) AGM 
					ON AGM.APPGROUPID = AM.APPGROUPID  
			) AS DARTAPPGROUPTotalRecordCount,
			(
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NOT NULL AND IsHavingSubBusinesss = 0
					AND CreatedBy = 'Migrated'
			) AS AppLensAPPGROUPTotalRecordCount,
			(
				SELECT COUNT(DISTINCT AGM.AppGroupName) FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				JOIN [AVMDART].[MAP].[LOBTRACKAPPLICATIONMAPPING] (NOLOCK) LTAM 
					ON LTAM.LOBTRACKID = TRACK.LOBTRACKID 
				JOIN [AVMDART].[MAS].[APPLICATIONMASTER] (NOLOCK) AM 
					ON AM.APPTRACKID = LTAM.APPLICATIONTRACKID
				JOIN [AVMDART].[MAP].[APPGROUPMASTER] (NOLOCK) AGM 
					ON AGM.APPGROUPID = AM.APPGROUPID AND ISNULL(AGM.IsDeleted, 'N') = 'N' AND ISNULL(AGM.IsHidden, 0) = 0
			) AS DARTAPPGROUPActiveRecordCount,
			(
				SELECT COUNT(BusinessClusterMapID) FROM AVL.BusinessClusterMapping (NOLOCK) 
				WHERE CustomerID = AppLensAccountID AND ParentBusinessClusterMapID IS NOT NULL AND IsHavingSubBusinesss = 0 
					AND IsDeleted = 0 AND CreatedBy = 'Migrated'
			) AS AppLensAPPGROUPActiveRecordCount,

			-- Application Master
			(
				SELECT COUNT(AM.ApplicationID) 
				FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				JOIN [AVMDART].[MAP].[LOBTRACKAPPLICATIONMAPPING] (NOLOCK) LTAM 
					ON LTAM.LOBTRACKID = TRACK.LOBTRACKID 
				JOIN [AVMDART].[MAS].[APPLICATIONMASTER] (NOLOCK) AM 
					ON AM.APPTRACKID = LTAM.APPLICATIONTRACKID
			) AS DARTApplicationTotalRecordCount,
			(
				SELECT COUNT(APP.ApplicationID) 
				FROM AVL.BusinessClusterMapping (NOLOCK) BCM
				JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) APP
					ON APP.SubBusinessClusterMapID = BCM.BusinessClusterMapID AND APP.CreatedBy = 'Migrated'
				WHERE BCM.CustomerID = AppLensAccountID AND BCM.ParentBusinessClusterMapID IS NOT NULL AND BCM.IsHavingSubBusinesss = 0
			) AS AppLensApplicationTotalRecordCount,
			(
				SELECT COUNT(AM.ApplicationID) 
				FROM AVMDART.MAP.LOBTRACKMAPPING (NOLOCK) TRACK
				JOIN AVMDART.MAP.ACCTPROJECTLOBMAPPING (NOLOCK) LOB
					ON LOB.ACCOUNTPROJECTLOBID = TRACK.ACCPROJECTLOBID
				JOIN @AppInventoryProjectDetails PRJ
					ON PRJ.DARTProjectID = LOB.ProjectID AND PRJ.ESAAccountID = P.ESAAccountID
				JOIN [AVMDART].[MAP].[LOBTRACKAPPLICATIONMAPPING] (NOLOCK) LTAM 
					ON LTAM.LOBTRACKID = TRACK.LOBTRACKID 
				JOIN [AVMDART].[MAS].[APPLICATIONMASTER] (NOLOCK) AM 
					ON AM.APPTRACKID = LTAM.APPLICATIONTRACKID AND ISNULL(AM.IsHidden, 0) = 0
			) AS DARTApplicationActiveRecordCount,
			(
				SELECT COUNT(APP.ApplicationID) 
				FROM AVL.BusinessClusterMapping (NOLOCK) BCM
				JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) APP
					ON APP.SubBusinessClusterMapID = BCM.BusinessClusterMapID AND APP.IsActive = 1 AND APP.CreatedBy = 'Migrated'
				WHERE BCM.CustomerID = AppLensAccountID AND BCM.ParentBusinessClusterMapID IS NOT NULL AND BCM.IsHavingSubBusinesss = 0
			) AS AppLensApplicationActiveRecordCount

		FROM @AppInventoryProjectDetails P
		ORDER BY ESAAccountID	
		----------------------------------- ITSM -----------------------------------

		SELECT ESAAccountID, DARTAccountName, AppLensAccountName, ESAProjectID, AppLensProjectName,

			-- Project SSIS Column Mapping
			(SELECT COUNT(SSIScmID) FROM AVMDART.PRJ.SSISColumnMapping (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTSSISColumnMappingTotalRecordCount,
			(SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPSSISColumnMappingTotalRecordCount,
			(SELECT COUNT(SSIScmID) FROM AVMDART.PRJ.SSISColumnMapping (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTSSISColumnMappingActiveRecordCount,
			(SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPSSISColumnMappingActiveRecordCount,
			-- Project SSIS Excel Column Mapping
			--(
			--	SELECT COUNT(SE.SSIScmID) FROM AVMDART.PRJ.SSISExcelColumnMapping (NOLOCK) SE
			--	JOIN AVMDART.MAS.Columnname (NOLOCK) CM
			--		ON CM.Name = SE.ProjectColumn AND ISNULL(CM.IsDeleted, 'N') = 'N'
			--	WHERE SE.ProjectID = DARTProjectID
			--) AS DARTSSISExcelColumnMappingTotalRecordCount,
			--(SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISExcelColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPSSISExcelColumnMappingTotalRecordCount,
			--(SELECT COUNT(SSIScmID) FROM AVMDART.PRJ.SSISExcelColumnMapping (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTSSISExcelColumnMappingActiveRecordCount,
			--(SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISExcelColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPSSISExcelColumnMappingActiveRecordCount,

			-- Service Project Mapping
			--(SELECT COUNT(ServProjMapID) FROM AVMDART.[MAP].[ServiceProjectMapping] (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTServiceProjectMappingTotalRecordCount,
			--(SELECT COUNT(ServProjMapID) FROM AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPServiceProjectMappingTotalRecordCount,
			--(SELECT COUNT(ServProjMapID) FROM AVMDART.[MAP].[ServiceProjectMapping] (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTServiceProjectMappingActiveRecordCount,
			--(SELECT COUNT(ServProjMapID) FROM AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPServiceProjectMappingActiveRecordCount,

			-- Project Ticket Type Mapping
			(SELECT COUNT(TicketTypeMappingID) FROM AVMDART.[PRJ].[TicketTypeMapping] (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTTicketTypeMappingTotalRecordCount,
			(SELECT COUNT(TicketTypeMappingID) FROM AVL.TK_MAP_TicketTypeMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPTicketTypeMappingTotalRecordCount,
			(SELECT COUNT(TicketTypeMappingID) FROM AVMDART.[PRJ].[TicketTypeMapping] (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTTicketTypeMappingActiveRecordCount,
			(SELECT COUNT(TicketTypeMappingID) FROM AVL.TK_MAP_TicketTypeMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPTicketTypeMappingActiveRecordCount,
		
			-- Project Ticket Type Service Mapping - TODO
			--(
			--	SELECT COUNT(*) FROM AVMDART.PRJ.DARTTicketTypeServiceMapping (NOLOCK) WHERE ProjectID = DARTProjectID
			--) AS DARTTicketTypeServiceMappingTotalRecordCount,
			--(SELECT COUNT(*) FROM AVL.TK_MAP_TicketTypeServiceMapping (NOLOCK) WHERE ProjectID = ALProjectID) AS APPTicketTypeServiceMappingTotalRecordCount,
			--(SELECT COUNT(*) FROM AVL.TK_MAP_TicketTypeServiceMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0) AS APPTicketTypeServiceMappingActiveRecordCount,
			
			-- Project Priority Mapping
			(SELECT COUNT(PriorityID) FROM AVMDART.PRJ.PriorityMaster (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTPriorityMappingTotalRecordCount,
			(SELECT COUNT(PriorityIDMapID) FROM AVL.TK_MAP_PriorityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPPriorityMappingTotalRecordCount,
			(SELECT COUNT(PriorityID) FROM AVMDART.PRJ.PriorityMaster (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTPriorityMappingActiveRecordCount,
			(SELECT COUNT(PriorityIDMapID) FROM AVL.TK_MAP_PriorityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPPriorityMappingActiveRecordCount,

			-- Project Severity Mapping
			(SELECT COUNT(SeverityID) FROM AVMDART.PRJ.ProjectSeverityDetails (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTSeverityMappingTotalRecordCount,
			(SELECT COUNT(SeverityIDMapID) FROM AVL.TK_MAP_SeverityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPSeverityMappingTotalRecordCount,
			(SELECT COUNT(SeverityID) FROM AVMDART.PRJ.ProjectSeverityDetails (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTSeverityMappingActiveRecordCount,
			(SELECT COUNT(SeverityIDMapID) FROM AVL.TK_MAP_SeverityMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPSeverityMappingActiveRecordCount,

			-- Project Status Mapping
			(SELECT COUNT(StatusID) FROM AVMDART.PRJ.StatusMaster (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTProjectStatusMappingTotalRecordCount,
			(SELECT COUNT(StatusID) FROM [AVL].[TK_MAP_ProjectStatusMapping] (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPProjectStatusMappingTotalRecordCount,
			(SELECT COUNT(StatusID) FROM AVMDART.PRJ.StatusMaster (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTProjectStatusMappingActiveRecordCount,
			(SELECT COUNT(StatusID) FROM [AVL].[TK_MAP_ProjectStatusMapping] (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPProjectStatusMappingActiveRecordCount,

			-- Project Cause Code
			(SELECT COUNT(CauseID) FROM AVMDART.[MAS].[DeptCauseCode] (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTCauseCodeTotalRecordCount,
			(SELECT COUNT(CauseID) FROM AVL.DEBT_MAP_CauseCode (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPCauseCodeTotalRecordCount,
			(SELECT COUNT(CauseID) FROM AVMDART.[MAS].[DeptCauseCode] (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTCauseCodeActiveRecordCount,
			(SELECT COUNT(CauseID) FROM AVL.DEBT_MAP_CauseCode (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPCauseCodeActiveRecordCount,

			-- Project Resolution Code
			(SELECT COUNT(ResolutionID) FROM AVMDART.MAS.DeptResolutionCode (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTResolutionCodeTotalRecordCount,
			(SELECT COUNT(ResolutionID) FROM AVL.DEBT_MAP_ResolutionCode (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPResolutionCodeTotalRecordCount,
			(SELECT COUNT(ResolutionID) FROM AVMDART.MAS.DeptResolutionCode (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTResolutionCodeActiveRecordCount,
			(SELECT COUNT(ResolutionID) FROM AVL.DEBT_MAP_ResolutionCode (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPResolutionCodeActiveRecordCount,

			-- Project Source Mapping
			(SELECT COUNT(SourceID) FROM AVMDART.PRJ.ProjectSourceDetails (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTProjectSourceMappingTotalRecordCount,
			(SELECT COUNT(SourceIDMapID) FROM AVL.TK_MAP_SourceMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPProjectSourceMappingTotalRecordCount,
			(SELECT COUNT(SourceID) FROM AVMDART.PRJ.ProjectSourceDetails (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTProjectSourceMappingActiveRecordCount,
			(SELECT COUNT(SourceIDMapID) FROM AVL.TK_MAP_SourceMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPProjectSourceMappingActiveRecordCount,

			-- Ticket Upload Project Configuration
			(SELECT COUNT(ProconfigID) FROM AVMDART.MAP.ProjectConfig (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTTicketUploadProjectConfigurationRecordCount,
			(SELECT COUNT(TicketUploadPrjConfigID) FROM dbo.TicketUploadProjectConfiguration (NOLOCK) WHERE ProjectID = ALProjectID) AS DARTTicketUploadProjectConfigurationRecordCount
		
		FROM @ProjectDetails
		ORDER BY ESAAccountID	

		--------------------------------------- Ticketing Module Configuration & Debt Configuration -----------------------------------

		SELECT ESAAccountID, DARTAccountName, AppLensAccountName, ESAProjectID, AppLensProjectName,
		
			-- Ticketing Module Configuration
			(SELECT COUNT(ProconfigID) FROM AVMDART.MAP.ProjectConfig (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTProjectConfigRecordCount,
			(SELECT COUNT(ProconfigID) FROM AVL.MAP_ProjectConfig (NOLOCK) WHERE ProjectID = ALProjectID) AS APPProjectConfigRecordCount,

			-- Project Debt Details
			(SELECT COUNT(Id) FROM AVMDART.MAS.ProjectDebtDetails (NOLOCK) WHERE ESAProjectID = P.ESAProjectID) AS DARTProjectDebtDetailsTotalRecordCount,
			(SELECT COUNT(ProjectDebtId) FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPProjectDebtDetailsTotalRecordCount,
			(SELECT COUNT(Id) FROM AVMDART.MAS.ProjectDebtDetails (NOLOCK) WHERE ESAProjectID = P.ESAProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTProjectDebtDetailsActiveRecordCount,
			(SELECT COUNT(ProjectDebtId) FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated' AND IsDeleted = 0) AS APPProjectDebtDetailsActiveRecordCount,

			-- Project Blended Rate Card Details
			(SELECT COUNT(BlendedRateID) FROM AVMDART.PRJ.BlendedRateCardDetails (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTBlendedRateCardDetailsTotalRecordCount,
			(SELECT COUNT(BlendedRateID) FROM AVL.Debt_BlendedRateCardDetails (NOLOCK) WHERE ProjectID = ALProjectID) AS APPBlendedRateCardDetailsTotalRecordCount,
			(SELECT COUNT(BlendedRateID) FROM AVMDART.PRJ.BlendedRateCardDetails (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTBlendedRateCardDetailsActiveRecordCount,
			(SELECT COUNT(BlendedRateID) FROM AVL.Debt_BlendedRateCardDetails (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0) AS APPBlendedRateCardDetailsActiveRecordCount,

			-- Heal Project Pattern Column Mapping
			(SELECT COUNT(ProjectPatternColumnMapID) FROM AVMDART.PRJ.Heal_ProjectPatternColumnMapping (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProjectPatternColumnMappingTotalRecordCount,
			(SELECT COUNT(ProjectPatternColumnMapID) FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealProjectPatternColumnMappingTotalRecordCount,
			(SELECT COUNT(ProjectPatternColumnMapID) FROM AVMDART.PRJ.Heal_ProjectPatternColumnMapping (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsActive, 'Y') = 'Y') AS DARTHealProjectPatternColumnMappingActiveRecordCount,
			(SELECT COUNT(ProjectPatternColumnMapID) FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK) WHERE ProjectID = ALProjectID AND IsActive = 1 AND CreatedBy = 'Migrated') AS APPHealProjectPatternColumnMappingActiveRecordCount,
			
			-- Heal Project Effort Configure State
			(SELECT COUNT(HealTypeId) FROM AVMDART.MAS.Heal_EffortConfigureState (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProjectEffortConfigureStateTotalRecordCount,
			(SELECT COUNT(HealTypeId) FROM AVL.Heal_EffortConfigureState (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealProjectEffortConfigureStateTotalRecordCount,
			(SELECT COUNT(HealTypeId) FROM AVMDART.MAS.Heal_EffortConfigureState (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTHealProjectEffortConfigureStateActiveRecordCount,
			(SELECT COUNT(HealTypeId) FROM AVL.Heal_EffortConfigureState (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPHealProjectEffortConfigureStateActiveRecordCount,
			
			-- Heal Project Threshold Master 
			(SELECT COUNT(Id) FROM AVMDART.MAS.Heal_ProjectThresholdMaster (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProjectThresholdMasterTotalRecordCount,
			(SELECT COUNT(Id) FROM AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealProjectThresholdMasterTotalRecordCount,
			(SELECT COUNT(Id) FROM AVMDART.MAS.Heal_ProjectThresholdMaster (NOLOCK) WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N') AS DARTHealProjectThresholdMasterActiveRecordCount,
			(SELECT COUNT(Id) FROM AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK) WHERE ProjectID = ALProjectID AND IsDeleted = 0 AND CreatedBy = 'Migrated') AS APPHealProjectThresholdMasterActiveRecordCount

		FROM @ProjectDetails P
		ORDER BY ESAAccountID	

		---------------------- Transactions - Data Dictionary, Ticket Master, Timesheet and Work Effort Elimination ----------------
		
		SELECT ESAAccountID, DARTAccountName, AppLensAccountName, ESAProjectID, AppLensProjectName, 

			-- Data Dictionary
			(SELECT COUNT(ID) FROM [AVMDART].[PRJ].[Debt_ProjectDataDictionaryID] (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTProjectDataDictionaryRecordCount,
			(SELECT COUNT(ID) FROM AVL.Debt_MAS_ProjectDataDictionary (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPProjectDataDictionaryRecordCount,

			-- Ticket Master / Details

			(
				SELECT COUNT(DISTINCT TicketID) 
				FROM AVMDART.PRJ.TicketMaster (NOLOCK) 
				WHERE ProjectID = DARTProjectID AND ISNULL(IsDeleted, 'N') = 'N' 
					AND OpenDate >= '2018-07-01'
			) AS DARTTicketMasterFromJulyRecordCount,
			(
				SELECT COUNT(DISTINCT TM.TicketID)
				FROM AVMDART.PRJ.TicketMaster (NOLOCK) TM
				JOIN AVMDART.PRJ.Timesheet (NOLOCK) DTS 
						ON DTS.ProjectId = TM.ProjectID AND DTS.TimesheetDate >= '2018-07-01'
				JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) DTD 
						ON DTD.ProjectId = TM.ProjectID AND DTD.TimesheetId = DTS.TimesheetId AND DTD.TicketNo = TM.TicketID 
				LEFT JOIN AVMDART.PRJ.TicketMaster (NOLOCK) TMJ  
						ON TMJ.ProjectID = TM.ProjectId AND TMJ.TicketID = TM.TicketID 
							AND ISNULL(TMJ.IsDeleted, 'N') = 'N' AND TMJ.OpenDate >= '2018-07-01'
				WHERE TM.ProjectID = DARTProjectID AND ISNULL(TM.IsDeleted, 'N') = 'N' 
					AND TMJ.ProjectID IS NULL
		
			) AS DARTTicketMasterBeforeJulyRecordCount,
			(SELECT COUNT(DISTINCT TicketID) FROM AVL.TK_TRN_TicketDetail (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPTicketMasterRecordCount,
			
			
			 --Timesheet - Tickets
			(
				SELECT COUNT(DISTINCT TS.TimesheetId) 
				FROM AVMDART.PRJ.Timesheet (NOLOCK) TS
				--JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) TSD
				--	ON TSD.TimesheetId = TS.TimesheetId AND TSD.ProjectId = TS.ProjectId 
					--AND TSD.ServiceId <> 41
				WHERE TS.ProjectID = DARTProjectID AND TS.TimesheetDate >= '2018-07-01'
			) AS DARTTimesheetRecordCount,
			(SELECT COUNT(TimesheetId) FROM AVL.TM_PRJ_Timesheet (NOLOCK) WHERE ProjectID = ALProjectID 
			--AND IsNonTicket = 0 
			AND CreatedBy = 'Migrated') AS APPTimesheetRecordCount,
		
			

			-- Timesheet Details - Tickets
			(
				SELECT COUNT(TD.TimeSheetDetailId) 
				FROM AVMDART.TRN.TimesheetDetail (NOLOCK) TD
				JOIN AVMDART.PRJ.Timesheet (NOLOCK) TS
					ON TS.TimesheetId = TD.TimesheetId AND TS.ProjectID = TD.ProjectID
						AND TS.TimesheetDate >= '2018-07-01' 
				WHERE TD.ProjectID = DARTProjectID
				 AND ISNULL(TD.ServiceId, '') <> 41 
			) AS DARTTimesheetDetailsRecordCount,
			(
				SELECT COUNT(TimeSheetDetailId) 
				FROM AVL.TM_TRN_TimesheetDetail (NOLOCK)
				WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated' AND ISNULL(ServiceId, '') <> 41 
			) AS APPTimesheetDetailsRecordCount,
			
			-- Timesheet - Non-Delivery Tickets
			--(
			--	SELECT COUNT(DISTINCT TS.TimesheetId) 
			--	FROM AVMDART.PRJ.Timesheet (NOLOCK) TS
			--	JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) TSD
			--		ON TSD.TimesheetId = TS.TimesheetId AND TSD.ProjectId = TS.ProjectId AND TSD.ServiceId = 41
			--	WHERE TS.ProjectID = DARTProjectID AND TS.TimesheetDate >= '2018-07-01'
			--) AS DARTNonDeliveryTimesheetRecordCount,
			--(SELECT COUNT(TimesheetId) FROM AVL.TM_PRJ_Timesheet (NOLOCK) WHERE ProjectID = ALProjectID AND IsNonTicket = 1 AND CreatedBy = 'Migrated') AS APPNonDeliveryTimesheetRecordCount,
		
			-- Timesheet Details - Non-Delivery Tickets
			(
				SELECT COUNT(TD.TimeSheetDetailId) 
				FROM AVMDART.TRN.TimesheetDetail (NOLOCK) TD
				JOIN AVMDART.PRJ.Timesheet (NOLOCK) TS
					ON TS.TimesheetId = TD.TimesheetId AND TS.ProjectID = TD.ProjectID
						AND TS.TimesheetDate >= '2018-07-01' 
				WHERE TD.ProjectID = DARTProjectID AND TD.ServiceId = 41 
			) AS DARTNonDeliveryTimesheetDetailsRecordCount,
			(
				SELECT COUNT(TimeSheetDetailId) 
				FROM AVL.TM_TRN_TimesheetDetail (NOLOCK)
				WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated' AND ServiceId = 41 
			) AS APPNonDeliveryTimesheetDetailsRecordCount

			----------- Work Effort Elimination -----------------
			---- Heal Project Pattern Mapping Dynamic
			--(SELECT COUNT(ProjectPatternMapID) FROM AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProjectPatternMappingDynamicTotalRecordCount,
			--(SELECT COUNT(ProjectPatternMapID) FROM AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealProjectPatternMappingDynamicTotalRecordCount,
			
			---- Heal Ticket Details
			----(SELECT COUNT(Id) FROM AVMDART.TRN.Heal_TicketDetails (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealTicketDetailsTotalRecordCount,
			----(SELECT COUNT(Id) FROM AVL.DEBT_TRN_HealTicketDetails (NOLOCK) WHERE ProjectID = ALProjectID) AS APPHealTicketDetailsTotalRecordCount,
			
			---- Heal Tickets Log
			--(SELECT COUNT(LogID) FROM AVMDART.TRN.Heal_TicketsLog (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealTicketsLogTotalRecordCount,
			--(SELECT COUNT(LogID) FROM AVL.DEBT_TRN_HealTicketsLog (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealTicketsLogTotalRecordCount,
			
			---- Heal Parent Child
			--(SELECT COUNT(Id) FROM AVMDART.PRJ.Heal_ParentChild (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealParentChildTotalRecordCount,
			--(SELECT COUNT(Id) FROM AVL.DEBT_PRJ_HealParentChild (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealParentChildTotalRecordCount,
			
			---- Heal Problem Ticket Master 
			--(SELECT COUNT(ProblemTicketMapID) FROM AVMDART.PRJ.Heal_ProblemTicketMaster (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProblemTicketMasterTotalRecordCount,
			--(SELECT COUNT(ProblemTicketMapID) FROM AVL.DEBT_PRJ_HealProblemTicketMaster (NOLOCK) WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPHealProblemTicketMasterTotalRecordCount--,
			
			-- Heal Problem Ticket Mapping
			--(SELECT COUNT(ID) FROM AVMDART.PRJ.Heal_ProblemTicketMapping (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealProblemTicketMappingTotalRecordCount,
			--(SELECT COUNT(ID) FROM AVL.DEBT_PRJ_HealProblemTicketMapping (NOLOCK) WHERE ProjectID = ALProjectID) AS APPHealProblemTicketMappingTotalRecordCount,
			
			-- Heal Re-Mapping Tickets
			--(SELECT COUNT(ID) FROM AVMDART.TRN.Heal_ReMappingTickets (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealReMappingTicketsTotalRecordCount,
			--(SELECT COUNT(ID) FROM AVL.Heal_ReMappingTickets (NOLOCK) WHERE ProjectID = ALProjectID) AS APPHealReMappingTicketsTotalRecordCount,
			
			-- Heal Problem Ticket Mapping
			--(SELECT COUNT(ID) FROM AVMDART.PRJ.Heal_DelinkMapping (NOLOCK) WHERE ProjectID = DARTProjectID) AS DARTHealDelinkMappingTotalRecordCount,
			--(SELECT COUNT(ID) FROM AVL.DEBT_PRJ_DelinkMapping (NOLOCK) WHERE ProjectID = ALProjectID) AS APPHealDelinkMappingTotalRecordCount

		FROM @ProjectDetails
		ORDER BY ESAAccountID	

	END TRY  
    BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

    END CATCH 
	
END
