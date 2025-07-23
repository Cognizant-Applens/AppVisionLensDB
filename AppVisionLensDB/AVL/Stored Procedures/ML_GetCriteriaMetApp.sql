/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ML_GetCriteriaMetApp] 
@ProjectID          BIGINT
AS 
  BEGIN 
      BEGIN TRY 

          DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @Optfieldupl NVARCHAR(50); 
          DECLARE @NoiseSentorReceived NVARCHAR(500); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidOptional DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
          DECLARE @InitialID BIGINT; 
          DECLARE @IsRegenerated BIT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidOptionalPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForOptional NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 
          DECLARE @IsAutoClassified NVARCHAR(10); 

          SET @InitialID=(SELECT TOP 1 ISNULL(ID, 0) 
                          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                          WHERE  ProjectID = @ProjectID 
                                 AND IsDeleted = 0 
                          ORDER  BY ID DESC) 
          SET @IsRegenerated=(SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                              FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                              WHERE  ProjectID = @ProjectID 
                                     AND IsDeleted = 0 
                              ORDER  BY ID DESC) 

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
                                               AND REG.InitialLearningID = @InitialID 
                                   WHERE  IT.ProjectID = @ProjectID); 
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
                                   WHERE  ProjectID = @ProjectID); 
                SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                        WHERE  ProjectID = @ProjectID 
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
                                      WHERE  ProjectID = @ProjectID 
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
                SET @IsConditionMetForOptional='N' 
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
                            SELECT 'Noise' AS CriteriaMet 
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
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
                            SELECT 'Noise' AS CriteriaMet 
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
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 


          --INSERT Error     
          EXEC AVL_INSERTERROR '[AVL].[ML_GetCriteriaMetApp]',  @ErrorMessage, @ProjectID,  0 
      END CATCH 
  END
