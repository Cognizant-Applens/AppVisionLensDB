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
-- Author:    683989 
-- Create date: 03-Jan-2020 
-- Description:   SP for Initial Learning 
-- [ML].[SaveSamplingDetails]  
-- =============================================  

CREATE PROCEDURE [ML].[SaveSamplingDetails] 
					(@UserId                 NVARCHAR(50), 
                     @ProjectID              NVARCHAR(200), 
                     @TVP_SavelstDebtTickets [ML].[SaveSampleUploadTickets] READONLY)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
		  DECLARE @IsDelete INT = 0;
		  DECLARE @InitialID BIGINT = 0;
		  SET @InitialID = (SELECT TOP 1 ID FROM ML.ConfigurationProgress WHERE  projectid = @ProjectID   
                  AND IsDeleted = @IsDelete ORDER BY ID DESC)	 

		  
          --saving sampled tickets from ui 
          CREATE TABLE #DEBTSAMPLETICKETS 
            ( 
               TicketId             NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
               TicketDescription    NVARCHAR(MAX) NULL, 
               AdditionalText       NVARCHAR(MAX) NULL, 
			   CauseCodeId          INT NULL, 
			   ResolutionCodeId     INT NULL, 
               DebtClassificationId INT NULL, 
               AvoidableFlagId      INT NULL, 
               ResidualDebtId       INT NULL,               
               DescBaseWorkPattern  NVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               DescSubWorkPattern   NVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               ResBaseWorkPattern   NVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               ResSubWorkPattern    NVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS
              
            ) 

          INSERT INTO #DEBTSAMPLETICKETS 
          SELECT TicketId, 
                 TicketDescription, 
                 AdditionalText,                  
                 CC.CauseID, 
				 RC.ResolutionID,
				 DC.DebtClassificationID,                  
				 AF.AvoidableFlagID, 
				 RD.ResidualDebtID,                  
                 TicketDescriptionPattern, 
                 TicketDescriptionSubPattern, 
                 RemarksPatternsResolution, 
                 ResolutionRemarkssubPattern
          FROM   @TVP_SavelstDebtTickets SD
		  JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC
			ON CC.CauseCode = SD.CauseCode
			AND CC.ProjectID = @ProjectID
			AND CC.IsDeleted = @IsDelete
          JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC
			ON RC.ResolutionCode=SD.ResolutionCode
			AND RC.ProjectID= @ProjectID
			AND RC.IsDeleted = @IsDelete
		  JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) DC
			ON DC.DebtClassificationName=SD.DebtClassificationName
          JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF
			ON AF.AvoidableFlagName=SD.AvoidableFlagName
			AND AF.IsDeleted = @IsDelete
		  JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD
			ON RD.ResidualDebtName=SD.ResidualDebt
			AND RD.IsDeleted = @IsDelete
		  


          SELECT TD.TimeTickerID          AS ID, 
				 TD.TicketID			  AS TicketID,
                 DST.DebtClassificationId AS DebtClassificationID, 
                 DST.AvoidableFlagId      AS AvoidableFlagID, 
                 DST.ResidualDebtId       AS ResidualDebtID, 
                 DST.CauseCodeId          AS CauseCodeID, 
                 DST.ResolutionCodeId     AS ResolutionCodeId,
				 TS.InitialLearningId	  AS InitialLearningId
          INTO   #TMPTICKET 
          FROM   ML.TRN_TICKETSAFTERSAMPLING(NOLOCK) TS 
                 JOIN #DEBTSAMPLETICKETS(NOLOCK) DST 
                   ON TS.TicketID = DST.TicketId 
                      AND TS.ProjectID = @ProjectID 
                      AND TS.IsDeleted = @IsDelete
					  AND TS.DebtClassifiedBy = 2
					  --AND DST.ApplicationID = TS.ApplicationID 
                      AND TS.Desc_Base_WorkPattern = DST.DescBaseWorkPattern 
                 JOIN AVL.TK_TRN_TICKETDETAIL TD 
                   ON TD.ProjectID = @ProjectID 
                      AND TD.IsDeleted = @IsDelete
					  AND TD.TicketID = DST.TicketId 
                      --AND TD.ApplicationID = DST.ApplicationID 

          -- updating debt fields from tvp to the ticketaftersampling table 

		  UPDATE TAS 
          SET    TAS.DebtClassificationID = TT.DebtClassificationID, 
                 TAS.AvoidableFlagID = TT.AvoidableFlagID, 
                 TAS.ResidualDebtID = TT.ResidualDebtID, 
                 TAS.CauseCodeID = TT.CauseCodeID, 
                 TAS.ResolutionCodeID = TT.ResolutionCodeId,
                 TAS.ModifiedBy = @UserId, 
                 TAS.ModifiedDate = GETDATE()      
          FROM   ML.TRN_TicketsAfterSampling TAS 
                 JOIN #TMPTICKET TT 
                   ON TT.TicketID = TAS.TicketID 
                      AND TAS.ProjectID = @ProjectID 
					  AND TT.InitialLearningId = TAS.InitialLearningId
					  WHERE TAS.InitialLearningId = @InitialID
          UPDATE TD 
          SET    TD.DebtClassificationMapID = TT.DebtClassificationID, 
                 TD.AvoidableFlag = TT.AvoidableFlagID, 
                 TD.ResidualDebtMapID = TT.ResidualDebtID, 
                 TD.CauseCodeMapID = TT.CauseCodeID, 
                 TD.ResolutionCodeMapID = TT.ResolutionCodeId, 
                 TD.LastUpdatedDate = GETDATE(), 
                 TD.ModifiedBy = @UserId, 
                 TD.ModifiedDate = GETDATE()
      
          FROM   AVL.TK_TRN_TICKETDETAIL TD 
                 JOIN #TMPTICKET TT 
                   ON TT.ID = TD.TimeTickerID 
                      AND TD.ProjectID = @ProjectID 
					  AND InitialLearningId = @InitialID

          ----updating [IsSamplingInProgress] as 'Saved' for resp projectid 
          UPDATE [ML].[ConfigurationProgress]
          SET    [IsSamplingInProgress] = 'saved' 
          WHERE  ProjectID = @ProjectID 
		  AND ID = @InitialID

          DECLARE @TotalTickets INT; 
          DECLARE @ValidTDescription INT; 
          DECLARE @ValidDebtFields INT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 

          SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) 
                             FROM   ML.TicketValidation(NOLOCK) 
                             WHERE  ProjectID = @ProjectID AND InitialLearningID = @InitialID); 
          SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID) 
                                  FROM   ML.TicketValidation(NOLOCK) 
                                  WHERE  ProjectID = @ProjectID 
                                         AND TicketDescription IS NOT NULL AND InitialLearningID = @InitialID); 
          SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID) 
                                FROM   ML.TicketValidation(NOLOCK) 
                                WHERE  ProjectID = @ProjectID 
                                       AND DebtClassificationId IS NOT NULL 
                                       AND AvoidableFlagID IS NOT NULL 
                                       AND CauseCodeID IS NOT NULL 
                                       AND ResolutionCodeID IS NOT NULL 
                                       AND ResidualDebtId IS NOT NULL
									   AND InitialLearningID = @InitialID) 
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
            '[ML].[SaveSamplingDetails] ', 
            @ErrorMessage, 
            @ProjectID, 
            @UserId 
      END CATCH 
  END
