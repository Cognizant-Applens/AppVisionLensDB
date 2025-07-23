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
-- [dbo].[ML_UpdateNoiseEliminationSkipOrCont] 202,'627384' 
-- =============================================  
CREATE PROCEDURE [dbo].[ML_UpdateNoiseEliminationSkipOrCont] --318,'627384' 
  @ProjectID BIGINT, 
  @UserID    NVARCHAR(500) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --to get latest id for initial learning  
          DECLARE @InitialidCHECK BIGINT 

          SET @InitialidCHECK=(SELECT TOP 1 ID 
                               FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                               WHERE  ProjectID = @ProjectID 
                                      AND IsDeleted = 0 
                               ORDER  BY ID DESC) 

          --updating IsNoiseSkipped as 1 because noise elimination is skipped and IsNoiseEliminationSentorReceived=Received
          UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
          SET    IsNoiseEliminationSentorReceived = 'Received', 
                 IsNoiseSkipped = 1, 
                 ModifiedBy = @UserID, 
                 ModifiedDate = GETDATE() 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 
                 AND ID = @InitialidCHECK 

          DELETE FROM AVL.ML_OPTIONALFIELDNOISEWORDS 
          WHERE  ProjectID = @ProjectID 

          DELETE FROM AVL.ML_TICKETDESCNOISEWORDS 
          WHERE  ProjectID = @ProjectID 

          DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @OptionalFieldID INT; 
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
          SET @OptionalFieldID=(SELECT OptionalFieldID 
                                FROM   AVL.ML_MAP_OPTIONALPROJMAPPING 
                                WHERE  ProjectId = @ProjectID 
                                       AND IsActive = 1) 

          SELECT @Optfieldupl = OptionalFieldupl, 
                 @NoiseSentorReceived = IsNoiseEliminationSentorReceived 
          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 

          --if it is regenerated initial learning transaction id 
          IF( @IsRegenerated = 1 ) 
            BEGIN 
                --Total ticket with application equal to Regenerated application id 
                SET @TotalTickets=(SELECT COUNT(DISTINCT IT.TicketID) 
                                   FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                          JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                            ON IT.ProjectID = REG.ProjectID 
                                               AND IT.ApplicationID = REG.ApplicationID 
                                               AND REG.InitialLearningID = @InitialID AND IT.IsDeleted=0
											   AND REG.IsDeleted=0
                                   WHERE  IT.ProjectID = @ProjectID); 
                -- Ticket with valid ticket description count and application id equal to regenerted application 
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
                -- valid  optional field count provided that applicationid equal to regenerated application id 
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
                --valid ticket with debt field count provided that applicationid equal to regenerated application id
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
                --Total ticket with application 
                SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) 
                                   FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                   WHERE  ProjectID = @ProjectID AND IsDeleted=0); 
                -- Ticket with valid ticket description count 
                SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                        WHERE  ProjectID = @ProjectID AND IsDeleted=0
                                               AND TicketDescription IS NOT NULL 
                                               AND TicketDescription <> ''); 
                -- valid  optional field count 
                SET @ValidOptional=(SELECT COUNT(DISTINCT TicketID) 
                                    FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                    WHERE  ProjectID = @ProjectID 
                                           AND OptionalFieldProj IS NOT NULL 
                                           AND OptionalFieldProj <> '' 
                                           AND IsDeleted = 0); 
                --valid ticket with debt field count  
                SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID) 
                                      FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                      WHERE  ProjectID = @ProjectID AND IsDeleted=0
                                             AND DebtClassificationId IS NOT NULL 
                                             AND AvoidableFlagID IS NOT NULL 
                                             AND CauseCodeID IS NOT NULL 
                                             AND ResolutionCodeID IS NOT NULL 
                                             AND ResidualDebtId IS NOT NULL) 
            --SELECT * FROM [TRN].[Debt_TicketsValidation]  
            END 

          --SELECT * FROM [TRN].[Debt_TicketsValidation]  
          --getting the percentage for tickdesc,optionalfield,debt fields 
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
                     OR @OptionalFieldId IS NULL ) 
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
                --if tickets are insufficient 
                SELECT 'Not Enough' AS CriteriaMet 
            END 
          --Block to check whether for sampling or for ticket upload/download or ML 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'Y' 
            BEGIN 
                --if Tdesc condition and debt field condn are met then it will go for ml after noise provided optional field 
                --if defined is filled for 80% 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      --condition is not met for optional field 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
                            --noise will always be done before sampling or ml 
                            SELECT 'Noise' AS CriteriaMet 
                        END 
                      ELSE 
                        BEGIN 
                            --after noise ml  
                            SELECT 'ML' AS CriteriaMet 
                        END 
                  END 
            --Direct ML 
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                --if cond not met debt fields along then it will go for sampling after noise provided that optional field cond is met
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
                      --if condition for ticketdesc is not met or optional field is not met it will go data extraction 
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
            'ML_UpdateNoiseEliminationSkipOrCont', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
