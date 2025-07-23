/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =======================================================================================  
-- Author:  Annadurai.S  
-- Create date: 22 June 2018
-- Description: Migration of Debt Configuration Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC SP_DataMigration_DebtConfiguration 1201185 ,'1000195935'
-- ======================================================================================= 

CREATE PROCEDURE [dbo].[SP_DataMigration_DebtConfiguration]
(
	@AccountId BIGINT, -- AVM DART ESA Account ID
	@ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
)

AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

		---------- Get all projects or specific project(s) for the Accounts ----------
		SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

		DECLARE @ProjectDetails TABLE 
		( 
			AccountID INT,
			AccountName NVARCHAR(MAX),
			ProjectID INT,
			EsaProjectID NVARCHAR(MAX),
			ProjectName VARCHAR(MAX)
		)
		
		INSERT INTO @ProjectDetails
			SELECT	DA.AccountID AS AccountID,
					AccountName,
					PM.ProjectID,
					PM.EsaProjectID,
					PM.ProjectName
			FROM AVMDART.MAS.ProjectMaster(NOLOCK) PM
			JOIN AVMDART.MAP.DeptAcctMapping(NOLOCK) DA
				ON DA.AccountID = @AccountId AND DA.DeptAccountID = PM.DeptAccountID 
					AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
			JOIN AVL.Customer (NOLOCK) cust
				ON cust.ESA_AccountID = DA.AccountID AND cust.IsDeleted = 0
		    JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
				ON APLPM.ESAProjectID = PM.ESAProjectID AND APLPM.IsDeleted = 0
			WHERE @ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)

		DROP TABLE #ESAProjectIds 

		------------------------------------------------ DEBT IDENTIFICATTION ---------------------------------------------------------

		---------- Push the data for Project Configuration Table ----------

		PRINT 'DEBT IDENTIFICATTION'

		INSERT INTO AVL.MAS_ProjectDebtDetails 
		(
			ProjectID,
			EsaProjectID,
			DebtEnablementDate,
			IsDeleted,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedDate,
			DebtControlDate,
			DebtControlFlag,
			IsTicketApprovalNeeded,
			EnablementSuperAdminId,
			ControlSuperAdminId,
			IsAutoClassified,
			AutoClassificationDate,
			IsMLSignOff,
			MLSignOffDate,
			MLSignOffUserId,
			AutoClassifiedBy,
			IsDDAutoClassified,
			IsDDAutoClassifiedDate,
			IsDDAutoClassifiedBy,
			IsCostTracked,
			DebtControlMethod,
			ISCLSIGNOFF,
			CLSIGNOFFDATE,
			CLSIGNOFFUSERID,
			IsManual,
			ManualDate
		)
		SELECT DISTINCT PM.ProjectID,
						PM.EsaProjectID,
						DARTPD.DebtEnablementDate,
						CASE WHEN DARTPD.IsDeleted = 'N' THEN 0 ELSE 1 END,
						'Migrated' AS CreatedBy,
						GETDATE() AS CreatedDate,
						NULL AS ModifiedBy,
						NULL AS ModifiedDate,
						DARTPD.DebtControlDate,
						DARTPD.DebtControlFlag,
						isnull(DARTPD.IsTicketApprovalNeeded,'N'),
						DARTPD.EnablementSuperAdminId,
						DARTPD.ControlsuperAdminId,
						DARTPD.IsAutoClassified,
						DARTPD.AutoClassificationDate,
						DARTPD.IsMLSignOff,
						DARTPD.MLSignOffDate,
						DARTPD.MLSignOffUserId,
						DARTPD.AutoClassifiedBy,
						DARTPD.IsDDAutoClassified,
						DARTPD.IsDDAutoClassifiedDate,
						DARTPD.IsDDAutoClassifiedBy,
						'Y' AS IsCostTracked,
						'A' AS DebtControlMethod,
						'' AS ISCLSIGNOFF,
						NULL AS CLSIGNOFFDATE,
						NULL AS CLSIGNOFFUSERID,
						CASE WHEN DARTPD.IsMLSignOff = 'Y' OR DARTPD.IsDDAutoClassified = 'Y' THEN 'N' ELSE 'Y' END 
						AS IsManual,
						CASE WHEN DARTPD.IsMLSignOff = 'Y' OR DARTPD.IsDDAutoClassified = 'Y' THEN NULL
							ELSE DARTPD.DebtEnablementDate END 
						AS ManualDate
		FROM AVMDART.MAS.ProjectDebtDetails(NOLOCK) DARTPD
		JOIN @ProjectDetails P
			ON P.EsaProjectID = DARTPD.EsaProjectID
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = P.ESAProjectID
		LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) ALPD
			ON ALPD.ProjectID = PM.ProjectID
		WHERE ALPD.ProjectID IS NULL

		---------- Update Project Master Table with Is Debt Enabled ----------	

		UPDATE AVL.MAS_ProjectMaster
		SET IsDebtEnabled = ADPM.IsDebtEnabled
		FROM AVL.MAS_ProjectMaster(NOLOCK) PM
		JOIN AVMDART.MAS.ProjectMaster(NOLOCK) ADPM
			ON ADPM.ESAProjectID = PM.ESAProjectID
		INNER JOIN @ProjectDetails P
			ON P.ESAProjectID = PM.ESAProjectID

		---------- Push the data for Blended Rate Card Details - Price of Debt ----------

		PRINT 'DEBT IDENTIFICATTION1'

		INSERT INTO AVL.Debt_BlendedRateCardDetails 
		(
			ProjectId,
			EffectiveFromDate,
			EffectiveToDate,
			BlendedRate,
			IsDeleted,
			CreatedBy,
			CreatedDate
		)
		SELECT	PM.ProjectId,
				DARTBRCD.EffectiveFromDate,
				DARTBRCD.EffectiveToDate,
				case when DARTBRCD.BlendedRate is NULL then 22 ELSE DARTBRCD.BlendedRate end ,
				CASE WHEN DARTBRCD.IsDeleted = 'N' THEN 0 ELSE 1 END,
				0 AS CreatedBy,
				GETDATE() AS CreatedDate
		FROM AVMDART.PRJ.BlendedRateCardDetails(NOLOCK) DARTBRCD
		JOIN @ProjectDetails PD
			ON PD.ProjectID = DARTBRCD.ProjectId
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.Debt_BlendedRateCardDetails(NOLOCK) BRCD
			ON BRCD.ProjectId = PM.ProjectID AND BRCD.EffectiveFromDate = DARTBRCD.EffectiveFromDate
				AND BRCD.EffectiveToDate = DARTBRCD.EffectiveToDate AND BRCD.BlendedRate = DARTBRCD.BlendedRate
		WHERE BRCD.ProjectId IS NULL


		INSERT INTO AVL.Debt_BlendedRateCardDetails 
		(
			ProjectId,
			EffectiveFromDate,
			EffectiveToDate,
			BlendedRate,
			IsDeleted,
			CreatedBy,
			CreatedDate
		)
		SELECT	PM.ProjectID,
				GETDATE(),
				NULL,
				22,
				0,
				0,
				GETDATE()
		FROM @ProjectDetails PD
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.Debt_BlendedRateCardDetails (NOLOCK) BRC
			ON BRC.ProjectID = PM.ProjectID
		WHERE BRC.ProjectID IS NULL

		PRINT 'END'
		-------------------------------------------------------------------------------------------------------------------------------

		------------------------------------------------ DEBT CONTROL ---------------------------------------------------------

		---------- Push the data for Heal Project Pattern Column Mapping Table ----------
		PRINT 'DEBT IDENTIFICATTION2'

		INSERT INTO AVL.DEBT_PRJ_HealProjectPatternColumnMapping 
		(
			ProjectID,
			ColumnID,
			IsActive,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedDate
		)
		SELECT	PM.ProjectID,
				ALHM.ColumnID,
				CASE WHEN DARTPPCM.IsActive = 'Y' THEN 1 ELSE 0 END,
				'Migrated' AS CreatedBy,
				GETDATE() AS CreatedDate,
				NULL AS ModifiedBy,
				NULL AS ModifiedDate
		FROM AVMDART.PRJ.Heal_ProjectPatternColumnMapping(NOLOCK) DARTPPCM
		JOIN @ProjectDetails PD
			ON PD.ProjectID = DARTPPCM.Projectid
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		JOIN AVMDART.MAS.Heal_ColumnMaster(NOLOCK) HM
			ON HM.ColumnID = DARTPPCM.ColumnID
		JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) ALHM
			ON ALHM.ColumnName = HM.ColumnName
		LEFT JOIN AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) PPCM
			ON PPCM.ProjectID = PM.ProjectID
			AND PPCM.ColumnID = ALHM.ColumnID
		WHERE PPCM.ProjectID IS NULL

		---------- Push the data for Projectwise Heal Effort Configure State  ----------
		PRINT 'DEBT IDENTIFICATTION3'

		INSERT INTO AVL.Heal_EffortConfigureState 
		(
			HealType,
			HealValue,
			HealMasterId,
			IsDeleted,
			ProjectID,
			ModifiedBY,
			LastModifiedDate,
			CreatedBY,
			CreateDateTime
		)
		SELECT	DARTHE.HealType,
				DARTHE.HealValue,
				HealTypeNumber AS HealMasterId,
				CASE WHEN DARTHE.IsDeleted = 'N' THEN 0 ELSE 1 END,
				PM.ProjectID,
				NULL AS ModifiedBY,
				NULL AS LastModifiedDate,
				'Migrated' AS CreatedBY,
				GETDATE() AS CreateDateTime
		FROM AVMDART.MAS.Heal_EffortConfigureState(NOLOCK) DARTHE
		JOIN @ProjectDetails PD
			ON PD.ProjectID = DARTHE.ProjectId
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.HealTypeMaster(NOLOCK) HM
			ON HM.HealTypeValue = DARTHE.HealType
		LEFT JOIN AVL.Heal_EffortConfigureState(NOLOCK) HE
			ON HE.ProjectID = PM.ProjectID AND HE.HealType = DARTHE.HealType
				AND HE.HealValue = DARTHE.HealValue
		WHERE HE.ProjectID IS NULL



		-----------------------IF Heal_EffortConfigureState data not found--------------


		INSERT INTO AVL.Heal_EffortConfigureState 
		(
			HealType,
			HealValue,
			HealMasterId,
			IsDeleted,
			ProjectID,
			ModifiedBY,
			LastModifiedDate,
			CreatedBY,
			CreateDateTime
		)
		SELECT	HM.HealTypeValue,
				HM.HealTypeNumber,
				HM.HealTypeNumber,
				0,
				PM.ProjectID,
				NULL,
				NULL,
				'Migrated',
				GETDATE()
		FROM @ProjectDetails PM
		JOIN AVL.HealTypeMaster HM ON 1 = 1
		LEFT JOIN AVL.Heal_EffortConfigureState (NOLOCK) HEC
			ON HEC.ProjectID = PM.ProjectID AND HM.HealTypeNumber = HEC.HealMasterId
		WHERE HEC.ProjectID IS NULL

		---------- Push the data for Projectwise Heal Threshold Master  ----------
		PRINT 'DEBT IDENTIFICATTION4'

		INSERT INTO AVL.DEBT_MAS_HealProjectThresholdMaster 
		(
			ProjectID,
			ThresholdCount,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedDate,
			IsDeleted
		)
		SELECT	PM.ProjectID,
				DARTPTM.ThresholdCount,
				'Migrated' AS CreatedBy,
				GETDATE() AS CreatedDate,
				NULL AS ModifiedBy,
				NULL AS ModifiedDate,
				CASE WHEN DARTPTM.IsDeleted = 'N' THEN 0 ELSE 1 END
		FROM AVMDART.MAS.Heal_ProjectThresholdMaster(NOLOCK) DARTPTM
		JOIN @ProjectDetails PD
			ON PD.ProjectID = DARTPTM.ProjectId
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.DEBT_MAS_HealProjectThresholdMaster(NOLOCK) PTM
			ON PTM.ProjectID = PM.ProjectID
			AND PTM.ThresholdCount = DARTPTM.ThresholdCount
		WHERE PTM.ProjectID IS NULL

		-- Insert Configuration Progress Logic for Debt Configuration Module
		DECLARE @ApplensAccountID BIGINT;

		SELECT @ApplensAccountID = PM.CustomerID
		FROM @ProjectDetails PD
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		JOIN AVL.Customer(NOLOCK) Cust
			ON Cust.ESA_AccountID = PD.AccountID AND Cust.CustomerID = pm.CustomerID
		WHERE cust.IsDeleted = 0 AND pm.IsDeleted = 0

		EXEC SP_DataMigration_InsertConfigurationProgress @ApplensAccountID, @ESAProjectIDs, 3

		-- Log the Debt Configuration migration is successful for the respective account.
		UPDATE DataMigrationLog
		SET DebtConfigStatus = 'S'
		WHERE AccountID = @AccountId

		COMMIT TRAN

	END TRY 
	BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

		ROLLBACK TRAN

		-- Log the Error in Data Migration Log Table.   
		UPDATE DataMigrationLog
		SET	DebtConfigStatus = 'F', DebtConfigErrorMessage = @ErrorMessage
		WHERE AccountID = @AccountId

	END CATCH

END
