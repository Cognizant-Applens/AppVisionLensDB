/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================
-- Author:		P. Anitha
-- Create Date: 9-Jul-2018
-- Description:	Migration of Data Dictionary Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--EXEC [dbo].[SP_DataMigration_DataDictionary] 1201185 ,'1000195935', 1
--EXEC [dbo].[SP_DataMigration_DataDictionary] 1207772,'1000162910'
--EXEC [dbo].[SP_DataMigration_DataDictionary] 1221627,'1000179446'
-- =========================================================================

CREATE PROCEDURE [dbo].[SP_DataMigration_DataDictionary]
(
	@ESA_AccountID BIGINT, -- ESA Account ID
	@ESAProjectIDs NVARCHAR(MAX), -- ESA Project IDs
	@IsIncrementalProject BIT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM DataMigrationLogInc (NOLOCK) WHERE AccountID = @ESA_AccountID AND ESAProjectID = @ESAProjectIDs) 
	BEGIN

		INSERT INTO DataMigrationLogInc
		(
			AccountID,
			ESAProjectID,
			DDStatus,
			TicketingModuleStatus,
			WorkEffortEliminationStatus,
			DDErrorMessage,
			TicketingModuleErrorMessage,
			WorkEffortEliminationErrorMessage
		)
		VALUES
		(
			@ESA_AccountID,
			@ESAProjectIDs,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
		)

	END 

	
	BEGIN TRY

		BEGIN TRAN

		--Added delete Proc by Annadurai on 12.10.2018 as per kumuthini's req
		PRINT @ESAProjectIDs

		EXEC [dbo].[SP_DataMigration_DeleteTransactionTables] @ESAProjectIDs

		-----------------------------------------------------------------------

		---------- Get all projects or specific project(s) for the Accounts ----------

		SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

		DECLARE @ActiveProjects TABLE
		(
			ProjectID BIGINT
		)

		SELECT PM.EsaProjectID, PM.ProjectID 
		INTO #AVL_ActiveProjects 
		FROM AVL.Customer (NOLOCK) C
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
			ON PM.CustomerID = C.CustomerID AND PM.IsDeleted = 0 AND C.IsDeleted = 0
		WHERE C.ESA_AccountID = @ESA_AccountID 
			AND (@ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds))

		DROP TABLE #ESAProjectIds


		INSERT INTO @ActiveProjects
			SELECT PM.ProjectID  
			FROM AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA 
			JOIN AVMDART.MAS.ProjectMaster (NOLOCK) PM 
				ON PM.DeptAccountID = DA.DeptAccountID AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
			WHERE PM.EsaProjectID IN (SELECT DISTINCT EsaProjectID FROM #AVL_ActiveProjects)


		CREATE TABLE #ProjectDataDictionary
		(
			D_EsaProjectID BIGINT,
			D_ProjectID BIGINT,
			D_ApplicationName NVARCHAR(100),
			D_CauseCode NVARCHAR(MAX),
			D_ResolutionCode NVARCHAR(MAX),
			D_DebtClassification NVARCHAR(MAX),
			D_AvoidableFlag NVARCHAR(MAX),
			D_ResidualDebt NVARCHAR(MAX),
			AVL_EsaProjectID BIGINT,
			AVL_ProjectID BIGINT,
			AVL_ApplicationID BIGINT,
			AVL_ApplicationName NVARCHAR(100),
			AVL_CauseCodeID BIGINT,
			AVL_ResolutionCodeID BIGINT,
			AVL_DebtClassificationID BIGINT,
			AVL_AvoidableFlagID BIGINT,
			AVL_ResidualDebtID BIGINT
		)

		-- Fetching DART Data Dictionary Values
		INSERT INTO #ProjectDataDictionary
			SELECT	PM.EsaProjectID AS DartPrj, 
					PM.ProjectID, 
					AA.ApplicationName,
					DCC.CauseCode AS CauseCode,
					DRC.ResolutionCode AS ResolutionCode,
					AFMD.AttributeTypeValue AS DebtClassification,
					AFM.AttributeTypeValue AS AvoidableFlag,
					AFMR.AttributeTypeValue AS ResidualDebt,
					AVL_PM.EsaProjectID,
					AVL_PM.ProjectID,
					AVL_AM.ApplicationID,
					AVL_AM.ApplicationName,
					NULL, NULL, NULL, NULL, NULL
			FROM [AVMDART].[PRJ].[Debt_ProjectDataDictionaryID] (NOLOCK) DDD
			JOIN [AVMDART].[MAS].[ProjectMaster] (NOLOCK) PM 
				ON DDD.ProjectID = PM.ProjectID
			JOIN AVL.MAS_ProjectMaster (NOLOCK) AVL_PM 
				ON PM.EsaProjectID = AVL_PM.EsaProjectID 
			JOIN [AVMDART].[MAS].[APPLICATIONMASTER] (NOLOCK) AA 
				ON DDD.APPLICATIONID = AA.APPLICATIONID
		 JOIN  AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) AVL_APM 
				ON AVL_PM.ProjectID = AVL_APM.ProjectID
			 JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AVL_AM 
				ON AA.ApplicationName = AVL_AM.ApplicationName AND AVL_APM.ApplicationID=AVL_AM.ApplicationID
			JOIN [AVMDART].[MAS].[DeptCauseCode] (NOLOCK) DCC 
				ON DDD.CauseCodeID = DCC.CauseID
			--JOIN [AVMDART].[MAS].[DeptCauseStatus] (NOLOCK) DCS ON DCS.StatusID = DCC.CauseStatusID
			JOIN [AVMDART].[MAS].[DeptResolutionCode] (NOLOCK) DRC 
				ON DDD.ResolutionCodeID = DRC.ResolutionID
			--JOIN [AVMDART].[MAS].[DeptResolutionStatus] (NOLOCK) DRS ON DRS.StatusID = DRC.ResolutionStatusID
			JOIN [AVMDART].[MAS].[AttributeFieldMAster] (NOLOCK) AFMD 
				ON AFMD.ID = DDD.DebtClassificationID
			JOIN [AVMDART].[MAS].[AttributeFieldMAster] (NOLOCK) AFM 
				ON AFM.ID = DDD.AvoidableFlagID
			JOIN [AVMDART].[MAS].[AttributeFieldMAster] (NOLOCK) AFMR 
				ON AFMR.ID = DDD.ResidualDebtID
			WHERE DDD.ProjectID IN (SELECT ProjectID FROM @ActiveProjects)

			--SELECT * FROM #ProjectDataDictionary

			--- Matching the Mappingid's for all the respective columns in DataDictionary from Applens Mapping Table

			UPDATE  T 
			SET T.AVL_CauseCodeID = CCM.CauseID,
				T.AVL_ResolutionCodeID = RCM.ResolutionID,
				T.AVL_DebtClassificationID = DC.DebtClassificationID,
				T.AVL_AvoidableFlagID = AF.AvoidableFlagID,
				T.AVL_ResidualDebtID = RD.ResidualDebtID
			FROM #ProjectDataDictionary T 
			LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CCM
				ON CCM.ProjectID = T.AVL_ProjectID AND CCM.CauseCode = T.D_CauseCode
			LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RCM 
				ON RCM.ProjectID = T.AVL_ProjectID AND RCM.ResolutionCode = T.D_ResolutionCode
			LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC
				ON DC.DebtClassificationName = T.D_DebtClassification
			LEFT JOIN AVL.DEBT_MAS_AvoidableFlag (NOLOCK) AF 
				ON AF.AvoidableFlagName = T.D_AvoidableFlag 
			LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD 
				ON RD.ResidualDebtName = T.D_ResidualDebt

			--SELECT * FROM #ProjectDataDictionary

			--- Inserting into Applens Data dictionary table
			INSERT INTO AVL.Debt_MAS_ProjectDataDictionary 
				SELECT	AVL_ProjectID, 
						AVL_ApplicationID,
						AVL_CauseCodeID,
						AVL_ResolutionCodeID,
						AVL_DebtClassificationID,
						AVL_AvoidableFlagID,
						AVL_ResidualDebtID,
						NULL,
						NULL,
						0,
						NULL,
						'Migrated',
						GETDATE(),
						NULL,
						NULL
				FROM #ProjectDataDictionary

			--SELECT * FROM #ProjectDataDictionary T

			-- Droping Temp Tables
			DROP Table #ProjectDataDictionary
			DROP TABLE #AVL_ActiveProjects

			-- Log the Data Dictionary migration is successful for the respective account.
			IF @IsIncrementalProject = 1
			BEGIN

				UPDATE DataMigrationLogInc SET DDStatus = 'S' 
				WHERE AccountID = @ESA_AccountID AND ESAProjectID = @ESAProjectIDs

			END
			ELSE
			BEGIN

				UPDATE DataMigrationLog SET DDStatus = 'S' WHERE AccountID = @ESA_AccountID

			END

		COMMIT TRAN

	END TRY  
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage
              
		ROLLBACK TRAN

		-- Log the Error in Data Migration Log Table.  
		IF @IsIncrementalProject = 1
		BEGIN 

			UPDATE DataMigrationLogInc SET DDStatus = 'F', DDErrorMessage = @ErrorMessage
			WHERE AccountID = @ESA_AccountID AND ESAProjectID = @ESAProjectIDs

		END
		ELSE
		BEGIN

			UPDATE DataMigrationLog SET DDStatus = 'F', DDErrorMessage = @ErrorMessage
			WHERE AccountID = @ESA_AccountID

		END
              
	END CATCH  

	
END
