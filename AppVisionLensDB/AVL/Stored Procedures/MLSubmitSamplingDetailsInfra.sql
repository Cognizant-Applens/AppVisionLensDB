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
-- Author:    471741  
-- Create date: 02-AUG-2019  
-- Description:   SP for Initial Learning  
-- [dbo].[ML_SubmitSamplingDetails]  

-- =============================================   
CREATE PROCEDURE [AVL].[MLSubmitSamplingDetailsInfra] (@UserId             NVARCHAR(50), 
                                             @ProjectID          NVARCHAR(200), 
                                             @TVP_lstDebtTickets [AVL].[InfraSaveDebtSampleTickets] READONLY)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --submit sampling details to ticketsafter sampling table  
          DECLARE @LatestID INT=0 
          DECLARE @InitialLearningId INT; 

          SET @LatestID = (SELECT TOP 1 id 
                           FROM   AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = 0 
                           ORDER  BY ID DESC) 
          SET @InitialLearningId=(SELECT ID 
                                  FROM   AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) 
                                  WHERE  ProjectID = @ProjectID 
                                         AND IsDeleted = 0 
                                         AND ID = @LatestID) 

          CREATE TABLE #DEBTSAMPLETICKETS 
            ( 
               TicketId             NVARCHAR(50) NULL, 
               TicketDescription    NVARCHAR(MAX) NULL, 
               AdditionalText       NVARCHAR(MAX), 
               DebtClassificationId INT NULL, 
               AvoidableFlagId      INT NULL, 
               ResidualDebtId       INT NULL, 
               CauseCodeId          INT NULL, 
               ResolutionCodeId     INT NULL, 
               DescBaseWorkPattern  NVARCHAR(1000), 
               DescSubWorkPattern   NVARCHAR(1000), 
               ResBaseWorkPattern   NVARCHAR(1000), 
               ResSubWorkPattern    NVARCHAR(1000), 
               TowerId              INT NULL 
            ) 

          INSERT INTO #DEBTSAMPLETICKETS 
          SELECT TicketId, 
                 TicketDescription, 
                 AdditionalText, 
                 DebtClassificationId, 
                 AvoidableFlagId, 
                 ResidualDebtId, 
                 CauseCodeId, 
                 ResolutionCodeId, 
                 DescBaseWorkPattern, 
                 DescSubWorkPattern, 
                 ResBaseWorkPattern, 
                 ResSubWorkPattern, 
                 TowerId 
          FROM   @TVP_lstDebtTickets 

          UPDATE DTS 
          SET    DTS.debtclassificationid = debt.DebtClassificationId 
          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern 
                 
                      AND DTS.TicketID = debt.TicketId 
          WHERE  DTS.ProjectID = @ProjectID 
                 AND DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern 
                  
                 AND DTS.TowerID = debt.TowerId 

          UPDATE DTS 
          SET    DTS.AvoidableFlagID = debt.AvoidableFlagID 
          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern 
                    
                      AND DTS.TicketID = debt.TicketId 
          WHERE  DTS.ProjectID = @ProjectID 
                 AND DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern 
                
                 AND DTS.TowerID = debt.TowerId 

          UPDATE DTS 
          SET    DTS.ResidualDebtID = debt.ResidualDebtId 
          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern 
                      AND DTS.TicketID = debt.TicketId 
          WHERE  DTS.ProjectID = @ProjectID 
                 AND DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern                  
                 AND DTS.TowerID = debt.TowerId 

          UPDATE DTS 
          SET    DTS.CauseCodeID = debt.CauseCodeId 
          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern                      
                      AND DTS.TicketID = debt.TicketId 

            WHERE  DTS.ProjectID = @ProjectID 
                 AND DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern                  
                 AND DTS.TowerID = debt.TowerId  

          UPDATE DTS 
          SET    DTS.ResolutionCodeID = debt.ResolutionCodeId 
          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern                      
                      AND DTS.TicketID = debt.TicketId 
          WHERE  DTS.ProjectID = @ProjectID 
                 AND DTS.Desc_Base_WorkPattern = debt.DescBaseWorkPattern                  
                 AND DTS.TowerID = debt.TowerId   

          UPDATE TD 
          SET    TD.Causecodemapid = TS.CauseCodeID, 
                 TD.DebtClassificationMapid = TS.DebtClassificationID, 
                 TD.ResidualdebtMapid = TS.ResidualDebtID, 
                 TD.Resolutioncodemapid = TS.ResolutionCodeID, 
                 TD.Avoidableflag = TS.AvoidableFlagID, 
                 TD.DebtClassificationMode = 7, 
                 TD.ModifiedDate = GETDATE(), 
                 TD.LastUpdatedDate = GETDATE(), 
                 TD.ModifiedBy = @UserId 
          FROM   AVL.TK_TRN_InfraTicketDetail TD 
                 INNER JOIN AVL.ML_TRN_TicketsAfterSamplingInfra TS 
                         ON TD.ticketid = TS.ticketid 
                            AND TD.projectid = TS.projectid 
                            AND TD.TowerID = TS.TowerID 
          WHERE  TD.ProjectID = @ProjectID 
                 AND TS.IsDeleted = 0 
                 AND TD.IsDeleted = 0 

          --updating [IsSamplingInProgress]=Submitted  
          UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
          SET    IsSamplingInProgress = 'Submitted' 
          WHERE  ProjectID = @ProjectID 
                 AND ID = @InitialLearningId 

          UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
          SET    IsMLSentOrReceived = 'Sent' 
          WHERE  ProjectID = @ProjectID 
                 AND ID = @InitialLearningId 

          --criteria check for ml  
          DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
          DECLARE @InitialID BIGINT; 
          DECLARE @IsRegenerated BIT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 

          SET @InitialID=(SELECT TOP 1 ISNULL(id, 0) 
                          FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                          WHERE  ProjectID = @ProjectID 
                                 AND IsDeleted = 0 
                          ORDER  BY ID DESC) 
          SET @IsRegenerated=(SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                              FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                              WHERE  ProjectID = @ProjectID 
                                     AND IsDeleted = 0 
                              ORDER  BY ID DESC) 

          IF( @IsRegenerated = 1 ) 
            BEGIN 
                SET @TotalTickets= (SELECT Count(*) 
                                    FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) IT 
                                           JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG 
                                             ON IT.ProjectID = REG.ProjectID 
                                                AND IT.TowerID = REG.TowerID 
                                                AND REG.InitialLearningID = @InitialID 
                                    WHERE  IT.ProjectID = @ProjectID); 
                SET @ValidTDescription= (SELECT Count(*) 
                                         FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) IT 
                                                JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG
                                                  ON IT.ProjectID = REG.ProjectID 
                                                     AND IT.TowerID = REG.TowerID 
                                                     AND REG.InitialLearningID = @InitialID 
                                         WHERE  IT.ProjectID = @ProjectID 
                                                AND IT.TicketDescription IS NOT NULL 
                                                AND IT.TicketDescription <> '' 
                                                AND IT.IsDeleted = 0 
                                                AND REG.IsDeleted = 0); 
                SET @ValidDebtFields= (SELECT Count(*) 
                                       FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) IT 
                                              JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG 
                                                ON IT.ProjectID = REG.ProjectID 
                                                   AND IT.TowerID = REG.TowerID 
                                                   AND REG.InitialLearningID = @InitialID 
                                       WHERE  IT.ProjectID = @ProjectID 
                                              AND REG.IsDeleted = 0 
                                              AND IT.IsDeleted = 0 
                                              AND IT.DebtClassificationID IS NOT NULL 
                                              AND IT.AvoidableFlagID IS NOT NULL 
                                              AND IT.CauseCodeID IS NOT NULL 
                                              AND IT.ResolutionCodeID IS NOT NULL 
                                              AND IT.ResidualDebtID IS NOT NULL) 
            END 
          ELSE 
            BEGIN 
                SET @TotalTickets=(SELECT Count(*) 
                                   FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) 
                                   WHERE  ProjectID = @ProjectID); 
                SET @ValidTDescription=(SELECT Count(*) 
                                        FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) 
                                        WHERE  ProjectID = @ProjectID 
                                               AND TicketDescription IS NOT NULL 
                                               AND TicketDescription <> ''); 
                SET @ValidDebtFields=(SELECT Count(*) 
                                      FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) 
                                      WHERE  ProjectID = @ProjectID 
                                             AND DebtClassificationID IS NOT NULL 
                                             AND AvoidableFlagID IS NOT NULL 
                                             AND CauseCodeID IS NOT NULL 
                                             AND ResolutionCodeID IS NOT NULL 
                                             AND ResidualDebtID IS NOT NULL) 
            END 

          SET @ValidTicketDescPercent= ( ( @ValidTDescription / @TotalTickets ) * 100 ); 
          SET @ValidTicketDebtFieldsPercent= ( ( @ValidDebtFields / @TotalTickets ) * 100 ); 

          IF @ValidTicketDescPercent >= 80 
            BEGIN 
                SET @IsConditionMetForTDesc='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForTDesc='N' 
            END 

          IF @ValidTicketDebtFieldsPercent >= 80 
            BEGIN 
                SET @IsConditionMetForDebtFields='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForDebtFields='N' 
            END 

          --Block to check whether for sampling or for ticket upload/download or ML  
          IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'Y' 
            BEGIN 
                SELECT 'ML' AS CriteriaMet 
            --Direct ML  
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                SELECT 'Sampling' AS CriteriaMet 
            --Sampling  
            END 
          ELSE 
            BEGIN 
                SELECT 'Excel' AS CriteriaMet 
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
            '[AVL].[MLSubmitSamplingDetailsInfra]', 
            @ErrorMessage, 
            @ProjectID, 
            @UserId 
      END CATCH 
  END
