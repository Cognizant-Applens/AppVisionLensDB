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
-- Author:    835658 
-- Create date: 16/07/2020
-- Description:   SP for Save Sampling details from grid
-- [ML].[Infra_SaveSamplingDetailsFromGrid]
-- =============================================  
CREATE PROCEDURE [ML].[Infra_SaveSamplingDetailsFromGrid] 
					(@UserId                 NVARCHAR(50), 
                     @ProjectID              NVARCHAR(200), 
                     @sampledData [ML].[SaveSampledTickets] READONLY)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
		  

		  DECLARE @IsDelete INT = 0,
				  @InitiId BIGINT;
          --saving sampled tickets from ui 
          CREATE TABLE #DEBTSAMPLETICKETS 
            ( 
               TicketId             NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,                 
			   CauseCodeId          INT NULL, 
			   ResolutionCodeId     INT NULL, 
               DebtClassificationId INT NULL, 
               AvoidableFlagId      INT NULL, 
               ResidualDebtId       INT NULL
            ) 

		  SET @InitiId = (SELECT TOP 1 ID FROM ML.InfraConfigurationProgress
							WHERE ProjectID = @ProjectID AND IsDeleted = @IsDelete
								ORDER BY ID DESC)

          INSERT INTO #DEBTSAMPLETICKETS 
          SELECT	TicketId,
					CauseCodeId,
					ResolutionCodeID,
					DebtClassificationID,
					AvoidableFlagID,
					ResidualDebtID
          FROM   @sampledData 
		  
          SELECT TD.TimeTickerID          AS ID, 
                 DST.DebtClassificationId AS DebtClassificationID, 
                 DST.AvoidableFlagId      AS AvoidableFlagID, 
                 DST.ResidualDebtId       AS ResidualDebtID, 
                 DST.CauseCodeId          AS CauseCodeID, 
                 DST.ResolutionCodeId     AS ResolutionCodeId 
          INTO   #TMPTICKET 
          FROM   ML.InfraTRN_TICKETSAFTERSAMPLING(NOLOCK) TS 
                 JOIN #DEBTSAMPLETICKETS(NOLOCK) DST 
                   ON TS.TicketID = DST.TicketId 
                      AND TS.ProjectID = @ProjectID 
                      AND TS.IsDeleted = @IsDelete	  
                 JOIN AVL.TK_TRN_INFRATICKETDETAIL TD 
                   ON TD.ProjectID = @ProjectID 
                      AND TD.IsDeleted = @IsDelete
					  AND TD.TicketID = DST.TicketId                       

          
          UPDATE TD 
          SET    TD.DebtClassificationMapID = TT.DebtClassificationID, 
                 TD.AvoidableFlag = TT.AvoidableFlagID, 
                 TD.ResidualDebtMapID = TT.ResidualDebtID, 
                 TD.CauseCodeMapID = TT.CauseCodeID, 
                 TD.ResolutionCodeMapID = TT.ResolutionCodeId, 
                 TD.LastUpdatedDate = GETDATE(), 
                 TD.ModifiedBy = @UserId, 
                 TD.ModifiedDate = GETDATE()
      
          FROM   AVL.TK_TRN_INFRATICKETDETAIL TD 
                 JOIN #TMPTICKET TT 
                   ON TT.ID = TD.TimeTickerID 
                      AND TD.ProjectID = @ProjectID 

          ----updating [IsSamplingInProgress] as 'Saved' for resp projectid 
          UPDATE [ML].[InfraConfigurationProgress]
          SET    [IsSamplingInProgress] = 'saved' 
          WHERE  ProjectID = @ProjectID AND ID = @InitiId

          DECLARE @TotalTickets INT; 
          DECLARE @ValidTDescription INT; 
          DECLARE @ValidDebtFields INT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 

          SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) 
                             FROM   ML.InfraTicketValidation(NOLOCK) 
                             WHERE  ProjectID = @ProjectID); 
          SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID) 
                             FROM   ML.InfraTicketValidation(NOLOCK) 
                                  WHERE  ProjectID = @ProjectID 
                                         AND TicketDescription IS NOT NULL); 
          SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID) 
                                FROM   ML.InfraTicketValidation(NOLOCK) 
                              WHERE  ProjectID = @ProjectID 
                                       AND DebtClassificationId IS NOT NULL 
                                       AND AvoidableFlagID IS NOT NULL 
                                       AND CauseCodeID IS NOT NULL 
                                       AND ResolutionCodeID IS NOT NULL 
                                       AND ResidualDebtId IS NOT NULL) 
          --SELECT * FROM [TRN].[Debt_TicketsValidation]  
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
            '[ML].[Infra_SaveSamplingDetailsFromGrid]', 
            @ErrorMessage, 
            @ProjectID, 
            @UserId 
      END CATCH 
  END
