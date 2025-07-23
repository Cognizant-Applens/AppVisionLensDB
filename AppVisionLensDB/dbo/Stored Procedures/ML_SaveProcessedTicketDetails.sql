/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Initial Learning 
-- =============================================  
CREATE PROCEDURE [dbo].[ML_SaveProcessedTicketDetails] (@ProjectID          NVARCHAR(200), 
                                                  @TVP_lstDebtTickets TVP_DEBTTICKETS READONLY, 
                                                  @DateFrom           DATETIME =NULL, 
                                                  @DateTo             DATETIME=NULL, 
                                                  @UserID             NVARCHAR(50)) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --To get the criteria for the project: Data Extraction,Noise,Sampling,ML 
          --IF Ticketdesc and optional(if defined) 80% not filled:Data Extraction 
          --Noise will happen once for each transaction id 
          --if debt fields are not filled 80% then sampling 
          --if all condition are satisfied the it will sent for ml 
          CREATE TABLE #DEBTTICKETS 
            ( 
               TicketId             NVARCHAR(1000) NULL, 
               TicketDescription    NVARCHAR(MAX) NULL, 
               ApplicationID        INT NULL, 
               DebtClassificationId INT NULL, 
               AvoidableFlagId      INT NULL, 
               CauseCode            INT NULL, 
               ResolutionCode       INT NULL, 
               ResidualDebtId       INT NULL, 
            ) 

          INSERT INTO #DEBTTICKETS 
          SELECT TicketId, 
                 TicketDescription, 
                 ApplicationID, 
                 DebtClassificationId, 
                 AvoidableFlagId, 
                 CauseCode, 
                 ResolutionCode, 
                 ResidualDebtId 
          FROM   @TVP_lstDebtTickets 

		  DECLARE @InitialID BIGINT; 

		  -- Latest transaction id in initialLearningstate table 
          SET @InitialID=(SELECT TOP 1 ISNULL(ID, 0) 
                          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                          WHERE  ProjectID = @ProjectID 
                                 AND IsDeleted = 0 
                          ORDER  BY ID DESC) 
		  DECLARE @IsMultiLingualEnabled INT = 0

			SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
			WHERE PM.ProjectID = @ProjectID
			AND PM.IsDeleted = 0)

		 

		  IF (@IsMultiLingualEnabled =1)
		  BEGIN

		 

		  DECLARE @TranslationCount INT = 0


      SET @TranslationCount = (SELECT COUNT(*) FROM 
	      [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] M 
		  INNER JOIN [AVL].[TK_TRN_TicketDetail] TD
		  ON TD.TimeTickerID = M.TimeTickerID
		  INNER JOIN #DEBTTICKETS TV
		  ON TV.TicketID = td.TicketID
		  AND TD.ProjectID = @ProjectID AND ISTICKETDESCRIPTIONUPDATED = 1 AND TD.Isdeleted = 0)
		  END
		  
          UPDATE #DEBTTICKETS 
          SET    TicketDescription = NULL 
          WHERE  TicketDescription = '' 

          UPDATE DVT 
          SET    DVT.TicketDescription = DT.TicketDescription 
          FROM   #DEBTTICKETS DT 
                 INNER JOIN AVL.ML_TRN_TICKETVALIDATION DVT 
                         ON DT.TicketId = DVT.TicketID 
                            AND DVT.ProjectId = @ProjectID 
                            AND DT.TicketDescription IS NULL 

          DECLARE @TotalTickets DECIMAL(18, 2); 
          
          DECLARE @IsRegenerated BIT; 
          DECLARE @OptionalFieldID INT; 
          DECLARE @Optfieldupl NVARCHAR(50); 
          DECLARE @NoiseSentorReceived NVARCHAR(500); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidOptional DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidOptionalPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForOptional NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 
          DECLARE @IsAutoClassified NVARCHAR(10); 

          
          --Regenerated transaction id or not 
          SET @IsRegenerated=(SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                              FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                              WHERE  ProjectID = @ProjectID 
                                     AND IsDeleted = 0 
                              ORDER  BY ID DESC) 
          --optional field id  
          SET @OptionalFieldID=(SELECT OptionalFieldID 
                                FROM   AVL.ML_MAP_OPTIONALPROJMAPPING 
                                WHERE  ProjectId = @ProjectID 
                                       AND IsActive = 1) 

          --if optional upload is skipped or not(if skipped the OptionalFieldupl=O  else it either M or null)
          SELECT @Optfieldupl = OptionalFieldupl, 
                 @NoiseSentorReceived = IsNoiseEliminationSentorReceived 
          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 

          IF( @IsRegenerated = 1 ) 
            BEGIN 
                SET @TotalTickets=(SELECT COUNT(DISTINCT IT.TicketID) 
                                   FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                          JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                            ON IT.ProjectID = REG.ProjectID 
                                               AND IT.ApplicationID = REG.ApplicationID 
                                               AND REG.InitialLearningID = @InitialID AND REG.IsDeleted=0
                                   WHERE  IT.ProjectID = @ProjectID AND IT.IsDeleted=0); 
                SET @ValidTDescription=(SELECT COUNT(DISTINCT IT.TicketID) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                               JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG
                                                 ON IT.ProjectID = REG.ProjectID 
                                                    AND IT.ApplicationID = REG.ApplicationID 
                                                    AND REG.InitialLearningID = @InitialID 
                                        WHERE  IT.ProjectID = @ProjectID 
                                               AND TicketDescription IS NOT NULL 
                                               AND TicketDescription <> '' 
                                               AND IT.IsDeleted = 0 
                                               AND REG.IsDeleted = 0); 
                SET @ValidOptional=(SELECT COUNT(DISTINCT IT.TicketID) 
                                    FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                           JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                             ON IT.ProjectID = REG.ProjectID 
                                                AND IT.ApplicationID = REG.ApplicationID 
                                                AND REG.InitialLearningID = @InitialID 
                                    WHERE  IT.ProjectID = @ProjectID 
                                           AND OptionalFieldProj IS NOT NULL 
                                           AND OptionalFieldProj <> '' 
                                           AND IT.IsDeleted = 0 
                                           AND REG.IsDeleted = 0); 
                SET @ValidDebtFields=(SELECT COUNT(DISTINCT IT.TicketID) 
                                      FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                               ON IT.ProjectID = REG.ProjectID 
                                                  AND IT.ApplicationID = REG.ApplicationID 
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
                SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) 
                                   FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                   WHERE  ProjectID = @ProjectID AND IsDeleted=0); 
                SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                        WHERE  ProjectID = @ProjectID  AND IsDeleted=0
                                               AND TicketDescription IS NOT NULL 
                                               AND TicketDescription <> ''); 
                SET @ValidOptional=(SELECT COUNT(DISTINCT TicketID) 
                                    FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                    WHERE  ProjectID = @ProjectID 
                                           AND OptionalFieldProj IS NOT NULL 
                                           AND OptionalFieldProj <> '' 
                                           AND IsDeleted = 0); 
                SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID) 
                                      FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                      WHERE  ProjectID = @ProjectID AND IsDeleted=0
                                             AND DebtClassificationId IS NOT NULL 
                                             AND AvoidableFlagID IS NOT NULL 
                                             AND CauseCodeID IS NOT NULL 
                                             AND ResolutionCodeID IS NOT NULL 
                                             AND ResidualDebtId IS NOT NULL) 
        
            END 

          SET @ValidTicketDescPercent= ( ( @ValidTDescription / @TotalTickets ) * 100 ); 
          SET @ValidOptionalPercent= ( ( @ValidOptional / @TotalTickets ) * 100 ); 
          SET @ValidTicketDebtFieldsPercent= ( ( @ValidDebtFields / @TotalTickets ) * 100 ); 
          SET @IsAutoClassified = (SELECT ISNULL(IsAutoClassified, 'N') AS IsAutoClassified 
                                   FROM   [AVL].[MAS_PROJECTDEBTDETAILS] 
                                   WHERE  ProjectID = @ProjectID 
                                          AND isdeleted = 0) 

          IF @ValidTicketDescPercent >= 80 
            BEGIN 
                SET @IsConditionMetForTDesc='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForTDesc='N' 
            END 

          IF @ValidOptionalPercent >= 80 
            BEGIN 
                SET @IsConditionMetForOptional='Y' 
            END 
          ELSE 
            BEGIN 
                IF( @OptionalFieldId = 4 
                     OR @OptionalFieldId IS NULL )--cond for optional field is calculated only if optional field is defined 
                  BEGIN 
                      SET @IsConditionMetForOptional='Y' 
                  END 
                ELSE 
                  BEGIN 
                      SET @IsConditionMetForOptional='N' 
                  END 
            END 

          IF @ValidTicketDebtFieldsPercent >= 80 
            BEGIN 
                SET @IsConditionMetForDebtFields='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForDebtFields='N' 
            END 

          IF @TotalTickets < 1000 
            BEGIN 
                SELECT 'Not Enough' AS CriteriaMet 
            END 
          --Block to check whether for sampling or for ticket upload/download or ML 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
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
						IF (@IsMultiLingualEnabled =1 AND @TranslationCount > 0)
						BEGIN
						SELECT'MultiLingual' AS CriteriaMet
						END
						ELSE
						BEGIN
                            SELECT 'Noise' AS CriteriaMet 
				     	END
                        END 
                      ELSE 
                        BEGIN 
                            SELECT 'ML' AS CriteriaMet 
                        END 
                  END 
            --Direct ML 
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' )--check for optional field upload skipped or not 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
						IF (@IsMultiLingualEnabled =1 AND @TranslationCount > 0)
						BEGIN
						SELECT'MultiLingual' AS CriteriaMet
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
            --Direct ML 
            END 
          ELSE IF @IsAutoClassified = 'N' 
            BEGIN 
                SELECT 'N' AS CriteriaMet 
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

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_SaveProcessedTicketDetails] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
