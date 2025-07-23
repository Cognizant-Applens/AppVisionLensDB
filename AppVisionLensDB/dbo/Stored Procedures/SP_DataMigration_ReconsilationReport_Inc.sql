/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================  
-- Author: Kumuthini 
-- Create date: 24 July 2018
-- Description: AVM DART APP LENS Migration Reconsilation Report
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC SP_DataMigration_ReconsilationReport '1223432, 1230064, 1224804, 1201125, 1222953', '1000083654,1000165665,1000171606,1000192711,1000217758,1000219016'
-- ================================================================================= 
-- EXEC SP_DataMigration_ReconsilationReport '1223432, 1201125, 1224804', '1000083654,1000192711,1000171606'
CREATE PROC [dbo].[SP_DataMigration_ReconsilationReport_Inc] 
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
			ON DARTPM.DeptAccountID = DACC.DeptAccountID
				AND DACC.IsDeleted = 'N'
				AND DARTPM.IsDeleted = 'N'
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
			ON APLPM.EsaProjectID = DARTPM.EsaProjectID AND APLPM.IsDeleted = 0
			--and APLPM.EsaProjectID='1000219080'
	     JOIN DataMigration_IncProjects (NOLOCK) DP ON DP.ProjectID = APLPM.ProjectID 
			and APLPM.EsaProjectID in ('1000219080'
)
		
				
	------------------------------------------------------------------------------------------
	BEGIN TRY

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
			
			-- Timesheet - Tickets
			(
				SELECT COUNT(DISTINCT TimesheetId) 
				FROM AVMDART.PRJ.Timesheet (NOLOCK)
				WHERE ProjectID = DARTProjectID AND TimesheetDate >= '2018-07-01'
			) AS DARTTimesheetRecordCount,
			(SELECT COUNT(DISTINCT TimesheetId) FROM AVL.TM_PRJ_Timesheet (NOLOCK) 
				WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated') AS APPTimesheetRecordCount,
		
			-- Timesheet Details - Tickets
			(
				SELECT COUNT(DISTINCT TD.TimeSheetDetailId) 
				FROM AVMDART.TRN.TimesheetDetail (NOLOCK) TD
				JOIN AVMDART.PRJ.Timesheet (NOLOCK) TS
					ON TS.TimesheetId = TD.TimesheetId AND TS.ProjectID = TD.ProjectID
						AND TS.TimesheetDate >= '2018-07-01' 
				WHERE TD.ProjectID = DARTProjectID AND ISNULL(TD.ServiceId, '') <> 41 
			) AS DARTTimesheetDetailsRecordCount,
			(
				SELECT COUNT(DISTINCT TimeSheetDetailId) 
				FROM AVL.TM_TRN_TimesheetDetail (NOLOCK)
				WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated' AND ISNULL(ServiceId, '') <> 41 
			) AS APPTimesheetDetailsRecordCount,
		
			-- Timesheet Details - Non-Delivery Tickets
			(
				SELECT COUNT(DISTINCT TD.TimeSheetDetailId) 
				FROM AVMDART.TRN.TimesheetDetail (NOLOCK) TD
				JOIN AVMDART.PRJ.Timesheet (NOLOCK) TS
					ON TS.TimesheetId = TD.TimesheetId AND TS.ProjectID = TD.ProjectID
						AND TS.TimesheetDate >= '2018-07-01' 
				WHERE TD.ProjectID = DARTProjectID AND TD.ServiceId = 41 
			) AS DARTNonDeliveryTimesheetDetailsRecordCount,
			(
				SELECT COUNT(DISTINCT TimeSheetDetailId) 
				FROM AVL.TM_TRN_TimesheetDetail (NOLOCK)
				WHERE ProjectID = ALProjectID AND CreatedBy = 'Migrated' AND ServiceId = 41 
			) AS APPNonDeliveryTimesheetDetailsRecordCount

		FROM @ProjectDetails
		ORDER BY ESAAccountID	

	END TRY  
    BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

    END CATCH 
	
END
