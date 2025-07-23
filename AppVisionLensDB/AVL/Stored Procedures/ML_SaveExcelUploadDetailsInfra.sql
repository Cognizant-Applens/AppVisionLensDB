/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================ 
-- Author:           Dhivya Bharathi M 
-- Create date:      31 July 2019    
-- Description:    SP for Initial Learning Upload

-- ============================================================================ 
CREATE PROCEDURE [AVL].[ML_SaveExcelUploadDetailsInfra] 
(@UserID                        NVARCHAR(50), 
 @ProjectID                     BIGINT, 
@TVP_lstDebtExcelUploadTickets TVP_SAVEDEBTUPLOADTICKETS READONLY,
 @OptionalFieldId               INT) 
AS 
BEGIN 
	BEGIN TRY 
	BEGIN TRAN 

	DECLARE @InitialID BIGINT; 
	DECLARE @isMultiLingual INT=0;
	DECLARE @IsResolutionRemarks [BIT]=0
	SET @InitialID = (SELECT TOP 1 ISNULL(ID, 0) 
						FROM   AVL.ML_PRJ_InitialLearningStateInfra (NOLOCK) 
						WHERE  ProjectID = @ProjectID  AND IsDeleted = 0 
						ORDER  BY ID DESC) 
	SELECT @isMultiLingual=1 FROM AVL.MAS_ProjectMaster (NOLOCK) 
						   WHERE ProjectID=@projectid AND IsDeleted=0 AND IsMultilingualEnabled=1;
	CREATE TABLE #DEBTUPLOADTICKETS 
	( 
	TicketId           NVARCHAR(50) NULL, 
	TicketDescription  NVARCHAR(MAX) NULL, 
	DebtClassification VARCHAR(50) NULL, 
	AvoidableFlag      VARCHAR(50) NULL, 
	CauseCode          VARCHAR(500) NULL, 
	ResolutionCode     VARCHAR(500) NULL, 
	ResidualDebt       VARCHAR(50) NULL, 
	OptionalFieldProj  NVARCHAR(MAX) NULL,
	IsTicketSummaryUpdated BIT NULL,
	IsTicketDescriptionUpdated BIT NULL 
	) 

	INSERT INTO #DEBTUPLOADTICKETS 
	SELECT TicketId,TicketDescription,DebtClassification,AvoidableFlag, 
	CauseCode,ResolutionCode,ResidualDebt,OptionalFieldProj,IsTicketDescriptionUpdated,IsTicketSummaryUpdated	  
	FROM   @TVP_lstDebtExcelUploadTickets 

	/*****************************Multilingual******************************/
	--NEED TO CHECK THIS MULTILINGUAL FLOW
	IF(@isMultiLingual=1)
		BEGIN
			SET @IsResolutionRemarks=(SELECT 1
									FROM AVL.MAS_MultilingualColumnMaster MCM  (NOLOCK) 
									JOIN AVL.PRJ_MultilingualColumnMapping MCP (NOLOCK) ON MCM.ColumnID=MCP.ColumnID
									WHERE MCM.IsActive=1 AND MCP.IsActive=1
									AND MCP.ProjectID=@projectid AND MCM.ColumnID=3);
	
			SELECT ITD.[TicketID],TD.TimeTickerID,ITD.IsTicketDescriptionUpdated,
			CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[OptionalFieldProj]=TD.ResolutionRemarks) 
			OR (ITD.[OptionalFieldProj]='') OR (ITD.[OptionalFieldProj] IS NULL)))
			OR (@IsResolutionRemarks !=1) OR (@OptionalFieldId != 1)
			THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified'
			INTO #MultilingualTbl2
			FROM  #DEBTUPLOADTICKETS ITD 
					LEFT JOIN AVL.TK_TRN_InfraTicketDetail TD (NOLOCK) ON TD.TicketID=ITD.[TicketID] 
					AND TD.ProjectID=@projectid AND TD.IsDeleted=0;

			UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID
			FROM #MultilingualTbl2 ITD 
			INNER JOIN AVL.TK_TRN_InfraTicketDetail TD (NOLOCK) 
			ON TD.TicketID=ITD.[TicketID] 
			WHERE TD.ProjectID=@projectid AND TD.IsDeleted=0;

			MERGE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] AS TARGET
			USING #MultilingualTbl2 AS SOURCE
			ON (Target.TimeTickerID=SOURCE.TimeTickerID)
			WHEN MATCHED  
			THEN 
			UPDATE SET TARGET.IsTicketDescriptionUpdated=(CASE WHEN SOURCE.IsTicketDescriptionUpdated=1 THEN 1 
															ELSE TARGET.IsTicketDescriptionUpdated END),
						TARGET.IsResolutionRemarksUpdated=(CASE WHEN SOURCE.IsResolutionRemarksModified=1 THEN 1
															ELSE TARGET.IsResolutionRemarksUpdated END),
						TARGET.ModifiedBy=@UserID,
						TARGET.ModifiedDate=GETDATE(),
						TARGET.TicketCreatedType=4,
						TARGET.ReferenceID = @InitialID
						WHEN NOT MATCHED BY TARGET 
			THEN 
			INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,
			Isdeleted,CreatedBy,CreatedDate,TicketCreatedType,ReferenceID ) 
			VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionUpdated,SOURCE.IsResolutionRemarksModified,
			0,@UserID,GETDATE(),4,@InitialID);
		END
	/**********************************************************************/
	SELECT ProjectID, TicketID,TicketDescription, DebtClassificationID, 
	AvoidableFlagID,ResolutionCodeID,CauseCodeID, ResidualDebtID 
	INTO   #TEMPFORTICKETDESCRIPTION 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) 
	WHERE  ProjectID = @ProjectID AND (TicketDescription IS NULL  OR TicketDescription = '' 
	AND TicketDescription != '***' )

	IF ( @OptionalFieldId = 1 ) 
		BEGIN 
			SELECT ProjectID, TicketID,TicketDescription, DebtClassificationID, 
			AvoidableFlagID,ResolutionCodeID,CauseCodeID, ResidualDebtID,OptionalFieldProj 
			INTO #TEMPFOROPTREST 
			FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) 
			WHERE  ProjectID = @ProjectID 
			--TO CHECK
			AND ( OptionalFieldProj IS NULL  OR OptionalFieldProj = '' )

			UPDATE ticket 
			SET    ticket.ResolutionRemarks = debt.OptionalFieldProj,ticket.[ModifiedBy] = @UserID,ticket.[ModifiedDate] = GETDATE() 
			FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ticket 
			JOIN #TEMPFOROPTREST (NOLOCK) X5 ON ticket.TicketId = X5.TicketID 
			JOIN #DEBTUPLOADTICKETS (NOLOCK) debt  ON debt.TicketId = X5.TicketID 
			WHERE  ticket.PROJECTID = @ProjectID  AND ( ticket.ResolutionRemarks IS NULL OR ticket.ResolutionRemarks = '' ) 
		END 
	UPDATE ITD 
	SET    ITD.TicketDescription = debt.TicketDescription,ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS (NOLOCK) debt  ON debt.TicketId = ITD.TicketID 
	WHERE  ITD.PROJECTID = @ProjectID 
	AND ( ITD.TicketDescription IS NULL  OR ITD.TicketDescription = '' ) 
	AND debt.TicketDescription <> '***' 

	UPDATE ITD 
	SET    ITD.OptionalFieldProj = debt.OptionalFieldProj,ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS (NOLOCK) debt  ON debt.TicketId = ITD.TicketID 
	WHERE  ITD.PROJECTID = @ProjectID 
	AND ( ITD.OptionalFieldProj IS NULL  OR ITD.OptionalFieldProj = '' ) 
	AND debt.OptionalFieldProj <> '***' 

	UPDATE ticket 
	SET    ticket.[TicketDescription] = debt.TicketDescription,ticket.[ModifiedBy] = @UserID,ticket.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ticket 
	JOIN #TEMPFORTICKETDESCRIPTION (NOLOCK) TD ON ticket.TicketId = TD.TicketID 
	JOIN #DEBTUPLOADTICKETS debt ON debt.TicketId = TD.TicketID 
	WHERE  ticket.PROJECTID = @ProjectID 
	AND ( TD.TicketDescription IS NULL OR TD.TicketDescription = '' ) 
	AND debt.TicketDescription <> '***' 


	UPDATE ITD 
	SET    ITD.DebtClassificationId = DC.[DebtClassificationID],ITD.[ModifiedBy] = @UserID, 
	ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS (NOLOCK) debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] (NOLOCK) DC ON debt.DebtClassification = DC.[DebtClassificationName] 
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.DebtClassificationId IS NULL  OR ITD.DebtClassificationId = 0 OR ITD.DebtClassificationId = '' ) 
	AND DC.IsDeleted = 0 

	UPDATE ITD 
	SET    ITD.[DebtClassificationMapID] = DC.[DebtClassificationID],ITD.[ModifiedBy] = @UserID,
	ITD.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] (NOLOCK) DC  ON debt.DebtClassification = DC.[DebtClassificationName] 
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[DebtClassificationMapID] IS NULL OR ITD.[DebtClassificationMapID] = 0 
	OR ITD.[DebtClassificationMapID] = '' ) 

	UPDATE ITD 
	SET ITD.[AvoidableFlagID] = AF.AvoidableFlagID, ITD.[ModifiedBy] = @UserID, ITD.[ModifiedDate] = GETDATE() 
	FROM AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt ON debt.TicketId = ITD.TicketID 
	JOIN AVL.DEBT_MAS_AVOIDABLEFLAG (NOLOCK) AF ON debt.AvoidableFlag = AF.AvoidableFlagName 
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[AvoidableFlagID] IS NULL  OR ITD.[AvoidableFlagID] = 0  OR ITD.[AvoidableFlagID] = '') 
	AND AF.IsDeleted = 0 

	UPDATE ITD 
	SET    ITD.[AvoidableFlag] = AF.AvoidableFlagID, ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt ON debt.TicketId = ITD.TicketID 
	JOIN AVL.DEBT_MAS_AVOIDABLEFLAG (NOLOCK) AF  ON debt.AvoidableFlag = AF.AvoidableFlagName 
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[AvoidableFlag] IS NULL OR ITD.[AvoidableFlag] = 0 OR ITD.[AvoidableFlag] = '' ) 

	UPDATE ITD 
	SET    ITD.ResidualDebtID = RB.[ResidualDebtID],ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] (NOLOCK) RB ON debt.ResidualDebt = RB.[ResidualDebtName] 
	WHERE  ITD.ProjectID = @ProjectID 
	AND (ITD.[ResidualDebtID] IS NULL OR ITD.[ResidualDebtID] = 0 OR ITD.[ResidualDebtID] = '') 
	AND RB.IsDeleted = 0 

	UPDATE ITD 
	SET    ITD.[ResidualDebtMapID] = RB.[ResidualDebtID], ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] (NOLOCK) RB ON debt.ResidualDebt = RB.[ResidualDebtName] 
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[ResidualDebtMapID] IS NULL OR ITD.[ResidualDebtMapID] = 0 OR ITD.[ResidualDebtMapID] = '' ) 

	UPDATE ITD 
	SET    ITD.[CauseCodeID] = CC.[CauseID], ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAP_CAUSECODE] (NOLOCK) CC  ON ITD.ProjectID = CC.ProjectID 
	AND debt.CauseCode = CC.[CauseCode]  AND CC.IsDeleted = 0  
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[CauseCodeID] IS NULL  OR ITD.[CauseCodeID] = 0 OR ITD.[CauseCodeID] = '' ) 

	UPDATE ITD 
	SET    ITD.[CauseCodeMapID] = CC.CauseID,ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAP_CAUSECODE] (NOLOCK) CC ON ITD.ProjectID = CC.ProjectID  AND
	debt.CauseCode = CC.CauseCode AND CC.IsDeleted = 0  
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[CauseCodeMapID] IS NULL  OR ITD.[CauseCodeMapID] = 0  OR ITD.[CauseCodeMapID] = '' ) 

	UPDATE ITD 
	SET    ITD.[ResolutionCodeID] = RC.ResolutionID, ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] (NOLOCK) RC  ON ITD.ProjectID = RC.ProjectID 
	AND debt.ResolutionCode = RC.ResolutionCode AND RC.IsDeleted = 0  
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[ResolutionCodeID] IS NULL  OR ITD.[ResolutionCodeID] = 0 OR ITD.[ResolutionCodeID] = '' ) 

	UPDATE ITD 
	SET ITD.[ResolutionCodeMapID] = RC.ResolutionID, ITD.[ModifiedBy] = @UserID,ITD.[ModifiedDate] = GETDATE() 
	FROM   [AVL].TK_TRN_InfraTicketDetail (NOLOCK) ITD 
	JOIN #DEBTUPLOADTICKETS debt  ON debt.TicketId = ITD.TicketID 
	JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] (NOLOCK) RC 
	ON ITD.ProjectID = RC.ProjectID AND debt.ResolutionCode = RC.ResolutionCode  AND RC.IsDeleted = 0  
	WHERE  ITD.ProjectID = @ProjectID 
	AND ( ITD.[ResolutionCodeMapID] IS NULL  OR ITD.[ResolutionCodeMapID] = 0   OR ITD.[ResolutionCodeMapID] = '' ) 
	
	--To get the Criteria Met
	 DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
      DECLARE @ValidOptional DECIMAL(18, 2); 
          DECLARE @Optfieldupl NVARCHAR(50); 
          DECLARE @NoiseSentorReceived NVARCHAR(500); 
         
          DECLARE @IsRegenerated BIT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @ValidOptionalPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @OptionalField INT; 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 
          DECLARE @IsConditionMetForOptional NVARCHAR(10); 

       
          SET @IsRegenerated = (SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_InitialLearningStateInfra (NOLOCK) 
                                WHERE  ProjectID = @ProjectID 
                                       AND IsDeleted = 0 
                                ORDER  BY ID DESC) 

          SELECT @Optfieldupl = OptionalFieldupl, 
                 @NoiseSentorReceived = IsNoiseEliminationSentorReceived 
          FROM   AVL.ML_PRJ_InitialLearningStateInfra (NOLOCK) 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 

          SELECT @OptionalField = OptionalFieldID 
          FROM   AVL.ML_MAP_OptionalProjMappingInfra (NOLOCK) 
          WHERE  ProjectId = @ProjectID 

          IF ( @IsRegenerated = 1 ) 
            BEGIN 
                SET @TotalTickets = (SELECT COUNT(IT.TicketID) 
                                     FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) IT 
                                            JOIN AVL.ML_TRN_RegeneratedTowerDetails (NOLOCK) REG
                                              ON IT.ProjectID = REG.ProjectID 
                                                 AND IT.TowerID = REG.TowerID 
                                                 AND REG.InitialLearningID = @InitialID and reg.IsDeleted=0
                                     WHERE  IT.ProjectID = @ProjectID AND IT.IsDeleted=0); 
                SET @ValidTDescription = (SELECT COUNT(IT.TicketID)
                                          FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) IT 
                                                 JOIN AVL.ML_TRN_RegeneratedTowerDetails (NOLOCK) REG
                                                   ON IT.ProjectID = REG.ProjectID 
                                                      AND IT.TowerID = REG.TowerID 
                                                      AND REG.InitialLearningID = @InitialID 
                                          WHERE  IT.ProjectID = @ProjectID 
                                                 AND TicketDescription IS NOT NULL 
                                                 AND TicketDescription <> '' 
                                                 AND IT.IsDeleted = 0 
                                                 AND REG.IsDeleted = 0); 
                SET @ValidOptional = (SELECT COUNT(IT.TicketID)
                                      FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) IT 
                                             JOIN AVL.ML_TRN_RegeneratedTowerDetails (NOLOCK) REG
                                               ON IT.ProjectID = REG.ProjectID 
                                                  AND IT.TowerID = REG.TowerID 
                                                  AND REG.InitialLearningID = @InitialID 
                                      WHERE  IT.ProjectID = @ProjectID 
                                             AND OptionalFieldProj IS NOT NULL 
                                             AND OptionalFieldProj <> '' 
                                             AND IT.IsDeleted = 0 
                                             AND REG.IsDeleted = 0); 
                SET @ValidDebtFields = (SELECT COUNT(IT.TicketID)
                                        FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) IT 
                                               JOIN AVL.ML_TRN_RegeneratedTowerDetails (NOLOCK) REG
                                                 ON IT.ProjectID = REG.ProjectID 
                                                    AND IT.TowerID = REG.TowerID 
                                                    AND REG.InitialLearningID = @InitialID 
                                        WHERE  IT.ProjectID = @ProjectID 
                                               AND REG.IsDeleted = 0 
                                               AND IT.IsDeleted = 0 
                                               AND DebtClassificationId IS NOT NULL 
                                               AND AvoidableFlagID IS NOT NULL 
                                               AND CauseCodeID IS NOT NULL 
                                               AND ResolutionCodeID IS NOT NULL 
                                               AND ResidualDebtId IS NOT NULL) 
            END 
          ELSE 
            BEGIN 
                SET @TotalTickets = (SELECT COUNT(TicketID)
                                     FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) 
                                     WHERE  ProjectID = @ProjectID AND IsDeleted=0); 
                SET @ValidTDescription = (SELECT COUNT(TicketID)
                                          FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) 
                                          WHERE  ProjectID = @ProjectID  and IsDeleted=0
                                                 AND TicketDescription IS NOT NULL 
                                                 AND TicketDescription <> ''); 
                SET @ValidOptional = (SELECT COUNT(TicketID)
                                      FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) 
                                      WHERE  ProjectID = @ProjectID and IsDeleted=0
                                             AND OptionalFieldProj IS NOT NULL 
                                             AND OptionalFieldProj <> '' 
                                             AND IsDeleted = 0); 
                SET @ValidDebtFields = (SELECT COUNT(TicketID) 
                                        FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) 
                                        WHERE  ProjectID = @ProjectID and IsDeleted=0
                                               AND DebtClassificationId IS NOT NULL 
                                               AND AvoidableFlagID IS NOT NULL 
                                               AND CauseCodeID IS NOT NULL 
                                               AND ResolutionCodeID IS NOT NULL 
                                               AND ResidualDebtId IS NOT NULL) 
            END 

          SET @ValidTicketDescPercent = ( ( @ValidTDescription / @TotalTickets ) * 100 ); 
          SET @ValidOptionalPercent = ( ( @ValidOptional / @TotalTickets ) * 100 ); 
          SET @ValidTicketDebtFieldsPercent = ( ( @ValidDebtFields / @TotalTickets ) * 100 ); 
		
          IF @ValidTicketDescPercent >= 80 
            BEGIN 
                SET @IsConditionMetForTDesc = 'Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForTDesc = 'N' 
            END 

          IF @ValidOptionalPercent >= 80 
            BEGIN 
                SET @IsConditionMetForOptional = 'Y' 
            END 
          ELSE 
            BEGIN 
                IF( @OptionalField = 4 
                     OR @OptionalField IS NULL ) 
                  BEGIN 
                      SET @IsConditionMetForOptional = 'Y' 
                  END 
                ELSE 
                  BEGIN 
                      SET @IsConditionMetForOptional = 'N' 
                  END 
            END 

          IF @ValidTicketDebtFieldsPercent >= 80 
            BEGIN 
                SET @IsConditionMetForDebtFields = 'Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForDebtFields = 'N' 
            END 

          -- Block to check whether for sampling or for ticket upload/download or ML 
          IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'Y' 
            BEGIN 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
						IF(@isMultiLingual=1)
	                 	BEGIN
						  SELECT 'MultiLingual' AS CriteriaMet 
						END
						ELSE
						BEGIN
						 
                            SELECT 'Noise' AS CriteriaMet 
                        END 
						END
                      ELSE 
                        BEGIN 
                            SELECT 'ML' AS CriteriaMet 

                            IF ( @ValidTicketDescPercent > @ValidTicketDebtFieldsPercent ) 
                              BEGIN 
                                  SELECT @ValidTicketDebtFieldsPercent AS ValidTicketPercentage 

                                  SELECT @ValidTicketDescPercent AS ValidTicketPercentagefordescription
                              END 
                            ELSE 
                              BEGIN 
                                  SELECT @ValidTicketDebtFieldsPercent AS ValidTicketPercentage 

                                  SELECT @ValidTicketDescPercent AS ValidTicketPercentagefordescription
                              END 
                        END 
                  --Direct ML 
                  END 
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
						IF(@isMultiLingual=1)
	                 	BEGIN
						  SELECT 'MultiLingual' AS CriteriaMet 
						END
						ELSE
						BEGIN
                            SELECT 'Noise' AS CriteriaMet 
                        END
						END 
                      ELSE 
                        BEGIN 
                            SELECT 'Sampling' AS CriteriaMet 
                        --Sampling 
                        END 
                  END 
            END 
          ELSE 
            BEGIN 
                IF @IsConditionMetForTDesc = 'N' 
                   AND @IsConditionMetForOptional = 'N' 
                  BEGIN 
                      SELECT 'TExcel' AS CriteriaMet 
                  END 
                ELSE IF @IsConditionMetForTDesc = 'N' 
                  BEGIN 
                      SELECT 'Excel' AS CriteriaMet 
                  END 
            --Download/Upload 
            END 

          COMMIT TRAN 
	END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 
          ROLLBACK TRAN 
          -- Insert Error     
          EXEC AVL_INSERTERROR  '[AVL].[ML_SaveExcelUploadDetailsInfra]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
