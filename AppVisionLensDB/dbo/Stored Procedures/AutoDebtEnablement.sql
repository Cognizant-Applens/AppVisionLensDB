/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Manoj, Shobana
-- Create date : 31 Dec 2018
-- Description : Procedure to enable the debt for the given list of projects automatically               
-- Test        : [dbo].[AutoDebtEnablement]
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [dbo].[AutoDebtEnablement]
(
	@AutoDebtDetails  [dbo].[AutoDebtClassification] READONLY
)
AS
BEGIN
  BEGIN TRY
   BEGIN TRAN

		-- Gets the Ticket Description for the projects
		SELECT SSCM.SERVICEDARTCOLUMN, PM.ProjectID 
		INTO #TicketDescription 
		FROM [AVL].[ITSM_PRJ_SSISColumnMapping] (NOLOCK) SSCM
		JOIN AVL.MAS_projectmaster (NOLOCK) PM 
			ON PM.ProjectID = SSCM.ProjectID AND SSCM.IsDeleted = 0
		JOIN @AutoDebtDetails AD
			ON AD.EsaProjectID = PM.EsaProjectID
		WHERE SSCM.SERVICEDARTCOLUMN = 'Ticket Description'
		GROUP BY SSCM.SERVICEDARTCOLUMN, PM.ProjectID

		-- Gets the projects which has completed ITSM Steps Ticket Status, Ticket Type, Cause Code and Resolution Code 
		SELECT PM.ProjectId, SUM(CompletionPercentage) AS Summ
		INTO #Prerequisite
		FROM [AVL].[PRJ_ConfigurationProgress] (NOLOCK) CP
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
		  ON PM.ProjectID = CP.ProjectID AND PM.IsDeleted = 0
		JOIN @AutoDebtDetails AD
		  ON AD.EsaProjectID = PM.EsaProjectID
		WHERE ScreenID = 2 AND ITSMScreenId IN (3,6,7,8) 
		GROUP BY PM.ProjectId


		-- Insert the project details into temporary table which satisfies following pre-requisites
		-- 1. Projects which has completed ITSM Steps Ticket Status, Ticket Type, Cause Code and Resolution Code 
		-- 2. If ML is enabled for the project, then Ticket Description should be included in Column Mapping
		SELECT DISTINCT 
				  PM.ProjectId,
				  PM.IsDeleted,
				  PM.CustomerID,
				  PM.IsDebtEnabled,
				  PM.IsMainSpRingConfigured,
				  AD.ClassificationMode,
				  AD.ClassificationEffectiveDate,
				  AD.EsaProjectID,
				  AD.DebtControlDate
		INTO #ProjectDetails 
		FROM [AVL].[PRJ_ConfigurationProgress] (NOLOCK) CP
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
			ON PM.ProjectID = CP.ProjectID AND PM.IsDeleted = 0
		JOIN @AutoDebtDetails AD
			ON AD.EsaProjectID = PM.EsaProjectID
		LEFT JOIN #TicketDescription (NOLOCK) Tic
			ON Tic.ProjectID = PM.ProjectID
		JOIN #Prerequisite (NOLOCK) PRE
			ON pre.ProjectID = PM.ProjectID
		WHERE (AD.ClassificationMode = 'ML' AND PRE.Summ = 400 AND Tic.ProjectID IS NOT NULL)
		    OR (AD.ClassificationMode IN ('Manual', 'DD') AND PRE.Summ = 400)
		GROUP BY PM.ProjectId, PM.IsDeleted, PM.CustomerID, PM.IsDebtEnabled, PM.IsMainSpringConfigured, AD.ClassificationMode,
			AD.ClassificationEffectiveDate, AD.EsaProjectID, AD.DebtControlDate

		SELECT * FROM #ProjectDetails

		-- Insert Debt failure ProjectIds  into Failure Log
		SELECT ESAProjectId 
		INTO ##DebtFailureLog
		FROM @AutoDebtDetails ADDE
		WHERE ADDE.ESAProjectId NOT IN 
		(SELECT ESAProjectId FROM #ProjectDetails)
 
		-- Insert / Update debt details into Project Debt Details table 
		MERGE AVL.MAS_ProjectDebtDetails PD
		USING #ProjectDetails PDD
				ON PDD.ProjectId = PD.ProjectId
		WHEN MATCHED THEN 

			UPDATE SET 
					PD.EsaProjectID = PDD.EsaProjectID,
					PD.IsTicketApprovalNeeded = CASE WHEN PD.IsTicketApprovalNeeded IS NULL THEN 'N' ELSE PD.IsTicketApprovalNeeded END,
					PD.DebtEnablementDate = CASE WHEN PD.DebtEnablementDate IS NULL THEN PDD.ClassificationEffectiveDate ELSE PD.DebtEnablementDate END,
					PD.IsCostTracked = CASE WHEN PD.IsCostTracked IS NULL THEN 'Y' ELSE PD.IsCostTracked END,
					PD.DebtControlMethod = CASE WHEN PD.DebtControlMethod IS NULL THEN 'A' ELSE PD.DebtControlMethod END,
					PD.IsManual = (CASE WHEN PDD.ClassificationMode = 'Manual' THEN 'Y' ELSE 'N' END) ,
					PD.IsAutoClassified = (CASE WHEN PDD.ClassificationMode = 'ML' THEN 'Y'  ELSE 'N' END),
					PD.IsDDAutoClassified = (CASE WHEN PDD.ClassificationMode = 'DD' THEN 'Y'  ELSE 'N' END) ,
					PD.ManualDate = (CASE WHEN PDD.ClassificationMode = 'Manual' THEN PDD.ClassificationEffectiveDate ELSE NULL END),
					PD.AutoClassificationDate = (CASE WHEN PDD.ClassificationMode = 'ML' THEN PDD.ClassificationEffectiveDate ELSE NULL END),
					PD.IsDDAutoClassifiedDate = (CASE WHEN PDD.ClassificationMode = 'DD' THEN PDD.ClassificationEffectiveDate ELSE NULL END),
					PD.DebtControlDate = CASE WHEN PD.DebtControlDate IS NULL THEN PDD.DebtControlDate ELSE PD.DebtControlDate END, 
					PD.DebtControlFlag = CASE WHEN PD.DebtControlFlag IS NULL THEN 'Y' ELSE PD.DebtControlFlag END, 
					PD.ModifiedBy = 'System',
					PD.ModifiedDate = GETDATE()
				                           
		WHEN NOT MATCHED BY TARGET THEN
			  
			INSERT
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
				ManualDate,
				IsCLAutoClassified,
				CLAutoClassifiedDate,
				CLAutoClassifiedBy
			)
			VALUES
			(
				PDD.ProjectID,
				PDD.EsaProjectID,
				PDD.ClassificationEffectiveDate, -- DebtEnablementDate
				0, -- IsDeleted
				'System', -- CreatedBy
				GETDATE(), -- CreatedDate
				NULL, -- ModifiedBy
				NULL, -- ModifiedDate
				PDD.DebtControlDate, -- DebtControlDate
				'Y',  -- DebtControlFlag
				'N',  -- IsTicketApprovalNeeded
				NULL, -- EnablementSuperAdminId
				NULL, -- ControlSuperAdminId
				CASE WHEN PDD.ClassificationMode = 'ML' THEN 'Y' ELSE 'N' END, -- IsAutoClassified
				CASE WHEN PDD.ClassificationMode = 'ML' THEN PDD.ClassificationEffectiveDate ELSE NULL END, -- AutoClassificationDate
				NULL, -- IsMLSignOff
				NULL, -- MLSignOffDate
				NULL, -- MLSignOffUserId
				NULL, -- AutoClassifiedBy
				CASE WHEN PDD.ClassificationMode = 'DD' THEN 'Y'  ELSE 'N' END, -- IsDDAutoClassified
				CASE WHEN PDD.ClassificationMode = 'DD' THEN PDD.ClassificationEffectiveDate  ELSE NULL END, -- IsDDAutoClassifiedDate
				NULL, -- IsDDAutoClassifiedBy
				'Y', -- IsCostTracked
				'A', -- DebtControlMethod
				NULL, -- ISCLSIGNOFF
				NULL, -- CLSIGNOFFDATE
				NULL, -- CLSIGNOFFUSERID
				CASE WHEN PDD.ClassificationMode = 'Manual' THEN 'Y'  ELSE 'N' END,   -- IsManual
				CASE WHEN PDD.ClassificationMode = 'Manual' THEN PDD.ClassificationEffectiveDate  ELSE NULL END,  -- ManualDate
				NULL, -- IsCLAutoClassified
				NULL, -- CLAutoClassifiedDate
				NULL  -- CLAutoClassifiedBy
			);
		 
		-- Update IsDebtEnabled Column in Project Master table
		UPDATE PM SET IsDebtEnabled = 'Y'
		FROM AVL.MAS_ProjectMaster (NOLOCK) PM
		JOIN #ProjectDetails (NOLOCK) PDD 
			ON PDD.ProjectID = PM.ProjectID
		 
		-- Insert into Blended Rate Card Details table
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
		FROM #ProjectDetails (NOLOCK) PD
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.Debt_BlendedRateCardDetails (NOLOCK) BRC
            ON BRC.ProjectID = PM.ProjectID
            WHERE BRC.ProjectID IS NULL 

	
		-- Insert values into Heal Effort Configure State for Simple, Medium and Complex
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
	           	PD.ProjectID,
	           	NULL,
	           	NULL,
	           	'System',
	           	GETDATE()
		FROM #ProjectDetails (NOLOCK) PD
		JOIN AVL.HealTypeMaster (NOLOCK) HM ON 1 = 1 
		LEFT JOIN AVL.Heal_EffortConfigureState (NOLOCK) HEC
         	ON HEC.ProjectID = PD.ProjectID 
        WHERE HEC.ProjectID IS NULL 
	  
		-- Insert values into Projectwise Heal Threshold Master
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
				1, -- ThresholdCount 
				'System' AS CreatedBy,
				GETDATE() AS CreatedDate,
				NULL AS ModifiedBy,
				NULL AS ModifiedDate,
				0 -- IsDeleted
		FROM #ProjectDetails (NOLOCK) PD
		JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
			ON PM.ESAProjectID = PD.ESAProjectID
		LEFT JOIN AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK) PTM
            ON PTM.ProjectID = PM.ProjectID
        WHERE PTM.ProjectID IS NULL

		-- Insert / Update completion percentage to 100 in the Project Configuration Progress table
		MERGE AVL.PRJ_ConfigurationProgress CP
		USING #ProjectDetails PDD
				ON PDD.ProjectId = CP.ProjectId AND CP.ScreenID = 5
    
		WHEN MATCHED THEN 

			UPDATE SET CP.CompletionPercentage = 100

		WHEN NOT MATCHED BY TARGET THEN 
				
			INSERT
			(
				CustomerID,
				ProjectID,
				ScreenID,
				ITSMScreenId,
				CompletionPercentage,
				IsDeleted,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsSeverity,
				IsDefaultPriority
			)
			VALUES
			(	
				PDD.CustomerID,
				PDD.ProjectID,
				5, -- ScreenID
				NULL, -- ITSMScreenId
				100, -- CompletionPercentage
				0, -- IsDeleted
				'System', -- CreatedBy
				GETDATE(), -- CreatedDate
				NULL, -- ModifiedBy
				NULL, -- ModifiedDate
				NULL, -- IsSeverity
				NULL -- IsDefaultPriority
			);
		
			-- Insert Ticket Attributes for the debt enabled projects
			DECLARE @ProjectCount AS INT
			DECLARE @ProjectLoopCounter AS INT = 1

			SELECT @ProjectCount = COUNT(ProjectId) FROM #ProjectDetails

			SELECT ROW_NUMBER() OVER (ORDER BY ProjectId ASC) AS RowNo, ProjectId, IsMainSpringConfigured
			INTO #AVLProjectIDs
			FROM #ProjectDetails

			DECLARE @AVLProjectID BIGINT
			DECLARE @IsMainSpring CHAR

			WHILE @ProjectLoopCounter <= @ProjectCount
			BEGIN

				SELECT @AVLProjectID = ProjectId, @IsMainSpring = ISNULL(IsMainSpringConfigured, 'N')
				FROM #AVLProjectIDs WHERE RowNo = @ProjectLoopCounter

				SELECT @AVLProjectID

				-- Insert Ticket Attributes for the debt enabled projects
				EXEC dbo.AutoDebt_InsertTicketAttributes
					@ProjectID = @AVLProjectID,
					@IsMainspring = @IsMainSpring

				SET @ProjectLoopCounter = @ProjectLoopCounter + 1

			END

	COMMIT TRAN

END TRY
	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);
		 
		ROLLBACK TRAN

		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
  END CATCH

END
